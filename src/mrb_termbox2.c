/* Configure termbox2 before including */
#define TB_OPT_ATTR_W 32
#define TB_OPT_EGC
#define TB_IMPL

#include "mruby.h"
#include "mruby/class.h"
#include "mruby/data.h"
#include "mruby/string.h"
#include "mruby/variable.h"
#include "mruby/error.h"
#include "termbox2.h"
#include <errno.h>

static struct RClass *tb2_module;
static struct RClass *tb2_error_class;
static struct RClass *tb2_event_class;

static const char *
tb2_strerror(int rv)
{
  if (rv == TB_ERR && tb_last_errno() == 0) {
    return "Termbox operation failed without errno";
  }
  return tb_strerror(rv);
}

static void
tb_event_free(mrb_state *mrb, void *ptr)
{
  mrb_free(mrb, ptr);
}

static const mrb_data_type tb_event_data_type = {
  "Termbox2::Event", tb_event_free
};

#define TB_CHECK(mrb, rv) do {                                      \
  if ((rv) < 0) {                                                   \
    mrb_raise(mrb, tb2_error_class, tb2_strerror(rv));              \
  }                                                                 \
} while (0)

#define TB_RETRY(rv, expr) do {                                     \
  do {                                                             \
    (rv) = (expr);                                                 \
  } while ((rv) < 0 && tb_last_errno() == EINTR);                  \
} while (0)

#define TB_RETRY_PRESENT(rv, expr) do {                             \
  do {                                                             \
    (rv) = (expr);                                                 \
  } while ((rv) < 0 &&                                             \
           (tb_last_errno() == EINTR || tb_last_errno() == EAGAIN || \
            ((rv) == TB_ERR && tb_last_errno() == 0)));            \
} while (0)

static mrb_value
new_event(mrb_state *mrb, const struct tb_event *ev)
{
  struct tb_event *copy = (struct tb_event *)mrb_malloc(mrb, sizeof(struct tb_event));
  *copy = *ev;
  return mrb_obj_value(mrb_data_object_alloc(mrb, tb2_event_class, copy, &tb_event_data_type));
}

/* Init/Shutdown */

static mrb_value
mrb_tb2_init(mrb_state *mrb, mrb_value self)
{
  int rv;
  TB_RETRY(rv, tb_init());
  TB_CHECK(mrb, rv);
  return mrb_nil_value();
}

static mrb_value
mrb_tb2_init_file(mrb_state *mrb, mrb_value self)
{
  const char *path;
  mrb_get_args(mrb, "z", &path);
  int rv;
  TB_RETRY(rv, tb_init_file(path));
  TB_CHECK(mrb, rv);
  return mrb_nil_value();
}

static mrb_value
mrb_tb2_init_fd(mrb_state *mrb, mrb_value self)
{
  mrb_int fd;
  mrb_get_args(mrb, "i", &fd);
  int rv;
  TB_RETRY(rv, tb_init_fd((int)fd));
  TB_CHECK(mrb, rv);
  return mrb_nil_value();
}

static mrb_value
mrb_tb2_init_rwfd(mrb_state *mrb, mrb_value self)
{
  mrb_int rfd, wfd;
  mrb_get_args(mrb, "ii", &rfd, &wfd);
  int rv;
  TB_RETRY(rv, tb_init_rwfd((int)rfd, (int)wfd));
  TB_CHECK(mrb, rv);
  return mrb_nil_value();
}

static mrb_value
mrb_tb2_shutdown(mrb_state *mrb, mrb_value self)
{
  int rv;
  TB_RETRY(rv, tb_shutdown());
  TB_CHECK(mrb, rv);
  return mrb_nil_value();
}

/* Screen */

static mrb_value
mrb_tb2_width(mrb_state *mrb, mrb_value self)
{
  int rv;
  TB_RETRY(rv, tb_width());
  TB_CHECK(mrb, rv);
  return mrb_fixnum_value(rv);
}

static mrb_value
mrb_tb2_height(mrb_state *mrb, mrb_value self)
{
  int rv;
  TB_RETRY(rv, tb_height());
  TB_CHECK(mrb, rv);
  return mrb_fixnum_value(rv);
}

static mrb_value
mrb_tb2_clear(mrb_state *mrb, mrb_value self)
{
  int rv;
  TB_RETRY(rv, tb_clear());
  TB_CHECK(mrb, rv);
  return mrb_nil_value();
}

static mrb_value
mrb_tb2_set_clear_attrs(mrb_state *mrb, mrb_value self)
{
  mrb_int fg, bg;
  mrb_get_args(mrb, "ii", &fg, &bg);
  int rv;
  TB_RETRY(rv, tb_set_clear_attrs((uintattr_t)fg, (uintattr_t)bg));
  TB_CHECK(mrb, rv);
  return mrb_nil_value();
}

static mrb_value
mrb_tb2_present(mrb_state *mrb, mrb_value self)
{
  int rv;
  TB_RETRY_PRESENT(rv, tb_present());
  TB_CHECK(mrb, rv);
  return mrb_nil_value();
}

static mrb_value
mrb_tb2_invalidate(mrb_state *mrb, mrb_value self)
{
  int rv;
  TB_RETRY(rv, tb_invalidate());
  TB_CHECK(mrb, rv);
  return mrb_nil_value();
}

/* Cursor */

static mrb_value
mrb_tb2_set_cursor(mrb_state *mrb, mrb_value self)
{
  mrb_int x, y;
  mrb_get_args(mrb, "ii", &x, &y);
  int rv;
  TB_RETRY(rv, tb_set_cursor((int)x, (int)y));
  TB_CHECK(mrb, rv);
  return mrb_nil_value();
}

static mrb_value
mrb_tb2_hide_cursor(mrb_state *mrb, mrb_value self)
{
  int rv;
  TB_RETRY(rv, tb_hide_cursor());
  TB_CHECK(mrb, rv);
  return mrb_nil_value();
}

/* Cells */

static mrb_value
mrb_tb2_set_cell(mrb_state *mrb, mrb_value self)
{
  mrb_int x, y, ch, fg, bg;
  mrb_get_args(mrb, "iiiii", &x, &y, &ch, &fg, &bg);
  int rv;
  TB_RETRY(rv, tb_set_cell((int)x, (int)y, (uint32_t)ch, (uintattr_t)fg, (uintattr_t)bg));
  TB_CHECK(mrb, rv);
  return mrb_nil_value();
}

static mrb_value
mrb_tb2_extend_cell(mrb_state *mrb, mrb_value self)
{
  mrb_int x, y, ch;
  mrb_get_args(mrb, "iii", &x, &y, &ch);
  int rv;
  TB_RETRY(rv, tb_extend_cell((int)x, (int)y, (uint32_t)ch));
  TB_CHECK(mrb, rv);
  return mrb_nil_value();
}

/* Modes */

static mrb_value
mrb_tb2_set_input_mode(mrb_state *mrb, mrb_value self)
{
  mrb_int mode;
  mrb_get_args(mrb, "i", &mode);
  int rv;
  TB_RETRY(rv, tb_set_input_mode((int)mode));
  TB_CHECK(mrb, rv);
  return mrb_fixnum_value(rv);
}

static mrb_value
mrb_tb2_set_output_mode(mrb_state *mrb, mrb_value self)
{
  mrb_int mode;
  mrb_get_args(mrb, "i", &mode);
  int rv;
  TB_RETRY(rv, tb_set_output_mode((int)mode));
  TB_CHECK(mrb, rv);
  return mrb_fixnum_value(rv);
}

/* Events */

static mrb_value
mrb_tb2_poll_event(mrb_state *mrb, mrb_value self)
{
  struct tb_event ev;
  int rv;
  TB_RETRY(rv, tb_poll_event(&ev));
  TB_CHECK(mrb, rv);
  return new_event(mrb, &ev);
}

static mrb_value
mrb_tb2_peek_event(mrb_state *mrb, mrb_value self)
{
  mrb_int timeout_ms;
  mrb_get_args(mrb, "i", &timeout_ms);
  struct tb_event ev;
  int rv;
  TB_RETRY(rv, tb_peek_event(&ev, (int)timeout_ms));
  if (rv == TB_ERR_NO_EVENT)
    return mrb_nil_value();
  TB_CHECK(mrb, rv);
  return new_event(mrb, &ev);
}

/* Output */

static mrb_value
mrb_tb2_print(mrb_state *mrb, mrb_value self)
{
  mrb_int x, y, fg, bg;
  const char *str;
  mrb_get_args(mrb, "iiiiz", &x, &y, &fg, &bg, &str);
  int rv;
  TB_RETRY(rv, tb_print((int)x, (int)y, (uintattr_t)fg, (uintattr_t)bg, str));
  TB_CHECK(mrb, rv);
  return mrb_nil_value();
}

/* Info */

static mrb_value
mrb_tb2_last_errno(mrb_state *mrb, mrb_value self)
{
  return mrb_fixnum_value(tb_last_errno());
}

static mrb_value
mrb_tb2_strerror(mrb_state *mrb, mrb_value self)
{
  mrb_int err;
  mrb_get_args(mrb, "i", &err);
  return mrb_str_new_cstr(mrb, tb_strerror((int)err));
}

static mrb_value
mrb_tb2_has_truecolor(mrb_state *mrb, mrb_value self)
{
  return mrb_bool_value(tb_has_truecolor());
}

static mrb_value
mrb_tb2_has_egc(mrb_state *mrb, mrb_value self)
{
  return mrb_bool_value(tb_has_egc());
}

static mrb_value
mrb_tb2_attr_width(mrb_state *mrb, mrb_value self)
{
  return mrb_fixnum_value(tb_attr_width());
}

static mrb_value
mrb_tb2_version(mrb_state *mrb, mrb_value self)
{
  return mrb_str_new_cstr(mrb, tb_version());
}

/* Event accessors */

static mrb_value
mrb_tb2_event_type(mrb_state *mrb, mrb_value self)
{
  struct tb_event *ev = (struct tb_event *)DATA_PTR(self);
  return mrb_fixnum_value(ev->type);
}

static mrb_value
mrb_tb2_event_mod(mrb_state *mrb, mrb_value self)
{
  struct tb_event *ev = (struct tb_event *)DATA_PTR(self);
  return mrb_fixnum_value(ev->mod);
}

static mrb_value
mrb_tb2_event_key(mrb_state *mrb, mrb_value self)
{
  struct tb_event *ev = (struct tb_event *)DATA_PTR(self);
  return mrb_fixnum_value(ev->key);
}

static mrb_value
mrb_tb2_event_ch(mrb_state *mrb, mrb_value self)
{
  struct tb_event *ev = (struct tb_event *)DATA_PTR(self);
  return mrb_fixnum_value(ev->ch);
}

static mrb_value
mrb_tb2_event_w(mrb_state *mrb, mrb_value self)
{
  struct tb_event *ev = (struct tb_event *)DATA_PTR(self);
  return mrb_fixnum_value(ev->w);
}

static mrb_value
mrb_tb2_event_h(mrb_state *mrb, mrb_value self)
{
  struct tb_event *ev = (struct tb_event *)DATA_PTR(self);
  return mrb_fixnum_value(ev->h);
}

static mrb_value
mrb_tb2_event_x(mrb_state *mrb, mrb_value self)
{
  struct tb_event *ev = (struct tb_event *)DATA_PTR(self);
  return mrb_fixnum_value(ev->x);
}

static mrb_value
mrb_tb2_event_y(mrb_state *mrb, mrb_value self)
{
  struct tb_event *ev = (struct tb_event *)DATA_PTR(self);
  return mrb_fixnum_value(ev->y);
}

/* Gem init/final */

void
mrb_mruby_termbox2_gem_init(mrb_state *mrb)
{
  tb2_module      = mrb_define_module(mrb, "Termbox2");
  tb2_error_class = mrb_define_class_under(mrb, tb2_module, "Error", mrb_class_get(mrb, "RuntimeError"));
  tb2_event_class = mrb_define_class_under(mrb, tb2_module, "Event", mrb->object_class);
  MRB_SET_INSTANCE_TT(tb2_event_class, MRB_TT_CDATA);

  /* Init/Shutdown */
  mrb_define_module_function(mrb, tb2_module, "init",       mrb_tb2_init,       MRB_ARGS_NONE());
  mrb_define_module_function(mrb, tb2_module, "init_file",  mrb_tb2_init_file,  MRB_ARGS_REQ(1));
  mrb_define_module_function(mrb, tb2_module, "init_fd",    mrb_tb2_init_fd,    MRB_ARGS_REQ(1));
  mrb_define_module_function(mrb, tb2_module, "init_rwfd",  mrb_tb2_init_rwfd,  MRB_ARGS_REQ(2));
  mrb_define_module_function(mrb, tb2_module, "shutdown",   mrb_tb2_shutdown,   MRB_ARGS_NONE());

  /* Screen */
  mrb_define_module_function(mrb, tb2_module, "width",            mrb_tb2_width,            MRB_ARGS_NONE());
  mrb_define_module_function(mrb, tb2_module, "height",           mrb_tb2_height,           MRB_ARGS_NONE());
  mrb_define_module_function(mrb, tb2_module, "clear",            mrb_tb2_clear,            MRB_ARGS_NONE());
  mrb_define_module_function(mrb, tb2_module, "set_clear_attrs",  mrb_tb2_set_clear_attrs,  MRB_ARGS_REQ(2));
  mrb_define_module_function(mrb, tb2_module, "present",          mrb_tb2_present,          MRB_ARGS_NONE());
  mrb_define_module_function(mrb, tb2_module, "invalidate",       mrb_tb2_invalidate,       MRB_ARGS_NONE());

  /* Cursor */
  mrb_define_module_function(mrb, tb2_module, "set_cursor",  mrb_tb2_set_cursor,  MRB_ARGS_REQ(2));
  mrb_define_module_function(mrb, tb2_module, "hide_cursor", mrb_tb2_hide_cursor, MRB_ARGS_NONE());

  /* Cells */
  mrb_define_module_function(mrb, tb2_module, "set_cell",    mrb_tb2_set_cell,    MRB_ARGS_REQ(5));
  mrb_define_module_function(mrb, tb2_module, "extend_cell", mrb_tb2_extend_cell, MRB_ARGS_REQ(3));

  /* Modes */
  mrb_define_module_function(mrb, tb2_module, "set_input_mode",  mrb_tb2_set_input_mode,  MRB_ARGS_REQ(1));
  mrb_define_module_function(mrb, tb2_module, "set_output_mode", mrb_tb2_set_output_mode, MRB_ARGS_REQ(1));

  /* Events */
  mrb_define_module_function(mrb, tb2_module, "poll_event", mrb_tb2_poll_event, MRB_ARGS_NONE());
  mrb_define_module_function(mrb, tb2_module, "peek_event", mrb_tb2_peek_event, MRB_ARGS_REQ(1));

  /* Output */
  mrb_define_module_function(mrb, tb2_module, "print", mrb_tb2_print, MRB_ARGS_REQ(5));

  /* Info */
  mrb_define_module_function(mrb, tb2_module, "last_errno",     mrb_tb2_last_errno,    MRB_ARGS_NONE());
  mrb_define_module_function(mrb, tb2_module, "strerror",       mrb_tb2_strerror,      MRB_ARGS_REQ(1));
  mrb_define_module_function(mrb, tb2_module, "has_truecolor?", mrb_tb2_has_truecolor, MRB_ARGS_NONE());
  mrb_define_module_function(mrb, tb2_module, "has_egc?",       mrb_tb2_has_egc,       MRB_ARGS_NONE());
  mrb_define_module_function(mrb, tb2_module, "attr_width",     mrb_tb2_attr_width,    MRB_ARGS_NONE());
  mrb_define_module_function(mrb, tb2_module, "version",        mrb_tb2_version,       MRB_ARGS_NONE());

  /* Event accessors */
  mrb_define_method(mrb, tb2_event_class, "type", mrb_tb2_event_type, MRB_ARGS_NONE());
  mrb_define_method(mrb, tb2_event_class, "mod",  mrb_tb2_event_mod,  MRB_ARGS_NONE());
  mrb_define_method(mrb, tb2_event_class, "key",  mrb_tb2_event_key,  MRB_ARGS_NONE());
  mrb_define_method(mrb, tb2_event_class, "ch",   mrb_tb2_event_ch,   MRB_ARGS_NONE());
  mrb_define_method(mrb, tb2_event_class, "w",    mrb_tb2_event_w,    MRB_ARGS_NONE());
  mrb_define_method(mrb, tb2_event_class, "h",    mrb_tb2_event_h,    MRB_ARGS_NONE());
  mrb_define_method(mrb, tb2_event_class, "x",    mrb_tb2_event_x,    MRB_ARGS_NONE());
  mrb_define_method(mrb, tb2_event_class, "y",    mrb_tb2_event_y,    MRB_ARGS_NONE());

  /* Constants */
#define TB_CONST(name) mrb_define_const(mrb, tb2_module, #name, mrb_fixnum_value((mrb_int)TB_##name))

  /* Colors */
  TB_CONST(DEFAULT);
  TB_CONST(BLACK);
  TB_CONST(RED);
  TB_CONST(GREEN);
  TB_CONST(YELLOW);
  TB_CONST(BLUE);
  TB_CONST(MAGENTA);
  TB_CONST(CYAN);
  TB_CONST(WHITE);

  /* Attributes (values depend on TB_OPT_ATTR_W) */
  TB_CONST(BOLD);
  TB_CONST(UNDERLINE);
  TB_CONST(REVERSE);
  TB_CONST(ITALIC);
  TB_CONST(BLINK);
  TB_CONST(HI_BLACK);
  TB_CONST(BRIGHT);
  TB_CONST(DIM);

  /* Event types */
  TB_CONST(EVENT_KEY);
  TB_CONST(EVENT_RESIZE);
  TB_CONST(EVENT_MOUSE);

  /* Key modifiers */
  TB_CONST(MOD_ALT);
  TB_CONST(MOD_CTRL);
  TB_CONST(MOD_SHIFT);
  TB_CONST(MOD_MOTION);

  /* Input modes */
  TB_CONST(INPUT_CURRENT);
  TB_CONST(INPUT_ESC);
  TB_CONST(INPUT_ALT);
  TB_CONST(INPUT_MOUSE);

  /* Output modes */
  TB_CONST(OUTPUT_CURRENT);
  TB_CONST(OUTPUT_NORMAL);
  TB_CONST(OUTPUT_256);
  TB_CONST(OUTPUT_216);
  TB_CONST(OUTPUT_GRAYSCALE);
  TB_CONST(OUTPUT_TRUECOLOR);

  /* Error codes */
  TB_CONST(OK);
  TB_CONST(ERR);
  TB_CONST(ERR_NEED_MORE);
  TB_CONST(ERR_INIT_ALREADY);
  TB_CONST(ERR_INIT_OPEN);
  TB_CONST(ERR_MEM);
  TB_CONST(ERR_NO_EVENT);
  TB_CONST(ERR_NO_TERM);
  TB_CONST(ERR_NOT_INIT);
  TB_CONST(ERR_OUT_OF_BOUNDS);
  TB_CONST(ERR_READ);
  TB_CONST(ERR_RESIZE_IOCTL);
  TB_CONST(ERR_RESIZE_PIPE);
  TB_CONST(ERR_RESIZE_SIGACTION);
  TB_CONST(ERR_POLL);
  TB_CONST(ERR_TCGETATTR);
  TB_CONST(ERR_TCSETATTR);
  TB_CONST(ERR_UNSUPPORTED_TERM);
  TB_CONST(ERR_RESIZE_WRITE);
  TB_CONST(ERR_RESIZE_POLL);
  TB_CONST(ERR_RESIZE_READ);
  TB_CONST(ERR_RESIZE_SSCANF);
  TB_CONST(ERR_CAP_COLLISION);

  /* ASCII key constants */
  TB_CONST(KEY_CTRL_TILDE);
  TB_CONST(KEY_CTRL_2);
  TB_CONST(KEY_CTRL_A);
  TB_CONST(KEY_CTRL_B);
  TB_CONST(KEY_CTRL_C);
  TB_CONST(KEY_CTRL_D);
  TB_CONST(KEY_CTRL_E);
  TB_CONST(KEY_CTRL_F);
  TB_CONST(KEY_CTRL_G);
  TB_CONST(KEY_BACKSPACE);
  TB_CONST(KEY_CTRL_H);
  TB_CONST(KEY_TAB);
  TB_CONST(KEY_CTRL_I);
  TB_CONST(KEY_CTRL_J);
  TB_CONST(KEY_CTRL_K);
  TB_CONST(KEY_CTRL_L);
  TB_CONST(KEY_ENTER);
  TB_CONST(KEY_CTRL_M);
  TB_CONST(KEY_CTRL_N);
  TB_CONST(KEY_CTRL_O);
  TB_CONST(KEY_CTRL_P);
  TB_CONST(KEY_CTRL_Q);
  TB_CONST(KEY_CTRL_R);
  TB_CONST(KEY_CTRL_S);
  TB_CONST(KEY_CTRL_T);
  TB_CONST(KEY_CTRL_U);
  TB_CONST(KEY_CTRL_V);
  TB_CONST(KEY_CTRL_W);
  TB_CONST(KEY_CTRL_X);
  TB_CONST(KEY_CTRL_Y);
  TB_CONST(KEY_CTRL_Z);
  TB_CONST(KEY_ESC);
  TB_CONST(KEY_CTRL_LSQ_BRACKET);
  TB_CONST(KEY_CTRL_3);
  TB_CONST(KEY_CTRL_4);
  TB_CONST(KEY_CTRL_BACKSLASH);
  TB_CONST(KEY_CTRL_5);
  TB_CONST(KEY_CTRL_RSQ_BRACKET);
  TB_CONST(KEY_CTRL_6);
  TB_CONST(KEY_CTRL_7);
  TB_CONST(KEY_CTRL_SLASH);
  TB_CONST(KEY_CTRL_UNDERSCORE);
  TB_CONST(KEY_SPACE);
  TB_CONST(KEY_BACKSPACE2);
  TB_CONST(KEY_CTRL_8);

  /* Terminal-dependent key constants */
  TB_CONST(KEY_F1);
  TB_CONST(KEY_F2);
  TB_CONST(KEY_F3);
  TB_CONST(KEY_F4);
  TB_CONST(KEY_F5);
  TB_CONST(KEY_F6);
  TB_CONST(KEY_F7);
  TB_CONST(KEY_F8);
  TB_CONST(KEY_F9);
  TB_CONST(KEY_F10);
  TB_CONST(KEY_F11);
  TB_CONST(KEY_F12);
  TB_CONST(KEY_INSERT);
  TB_CONST(KEY_DELETE);
  TB_CONST(KEY_HOME);
  TB_CONST(KEY_END);
  TB_CONST(KEY_PGUP);
  TB_CONST(KEY_PGDN);
  TB_CONST(KEY_ARROW_UP);
  TB_CONST(KEY_ARROW_DOWN);
  TB_CONST(KEY_ARROW_LEFT);
  TB_CONST(KEY_ARROW_RIGHT);
  TB_CONST(KEY_BACK_TAB);
  TB_CONST(KEY_MOUSE_LEFT);
  TB_CONST(KEY_MOUSE_RIGHT);
  TB_CONST(KEY_MOUSE_MIDDLE);
  TB_CONST(KEY_MOUSE_RELEASE);
  TB_CONST(KEY_MOUSE_WHEEL_UP);
  TB_CONST(KEY_MOUSE_WHEEL_DOWN);

#undef TB_CONST
}

void
mrb_mruby_termbox2_gem_final(mrb_state *mrb)
{
  tb_shutdown(); /* safety net, no-op if not initialized */
}
