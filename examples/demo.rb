# examples/demo.rb
# Interactive mruby-termbox2 feature demo
#
# Navigation:
#   <- ->   change page          1-4   jump to page
#   h / l   change page (vim)    m     toggle mouse
#   q       quit

PAGES = ["Basic Colors", "256 Colors", "Truecolor", "Event Log"]

$page     = 0
$events   = []
$mouse_on = false
$mouse_x  = 0
$mouse_y  = 0

# ── colors & attributes used across pages ────────────────────────────────

NAMED_COLORS = [
  [Termbox2::DEFAULT, "DEFAULT"],
  [Termbox2::BLACK,   "BLACK"],
  [Termbox2::RED,     "RED"],
  [Termbox2::GREEN,   "GREEN"],
  [Termbox2::YELLOW,  "YELLOW"],
  [Termbox2::BLUE,    "BLUE"],
  [Termbox2::MAGENTA, "MAGENTA"],
  [Termbox2::CYAN,    "CYAN"],
  [Termbox2::WHITE,   "WHITE"],
]

NAMED_ATTRS = [
  [0,                   "Normal"],
  [Termbox2::BOLD,      "Bold"],
  [Termbox2::ITALIC,    "Italic"],
  [Termbox2::UNDERLINE, "Underline"],
  [Termbox2::REVERSE,   "Reverse"],
  [Termbox2::BLINK,     "Blink"],
  [Termbox2::DIM,       "Dim"],
  [Termbox2::BRIGHT,    "Bright"],
]

# ── helper: fill a full-width row with bg color ───────────────────────────

def hline(y, fg, bg)
  Termbox2.width.times { |x| Termbox2.set_cell(x, y, 0x20, fg, bg) }
end

# ── helper: convert HSV to 0xRRGGBB (for truecolor gradients) ────────────

def hsv_rgb(h, s, v)
  h = h % 360.0
  c = v * s
  x = c * (1.0 - ((h / 60.0) % 2.0 - 1.0).abs)
  m = v - c
  r, g, b = case (h / 60.0).to_i
    when 0 then [c, x, 0.0]
    when 1 then [x, c, 0.0]
    when 2 then [0.0, c, x]
    when 3 then [0.0, x, c]
    when 4 then [x, 0.0, c]
    else        [c, 0.0, x]
  end
  (((r + m) * 255).to_i << 16) |
  (((g + m) * 255).to_i << 8)  |
   ((b + m) * 255).to_i
end

# ── helper: gradient bar (truecolor) ─────────────────────────────────────

def gradient_bar(x, y, w, color_fn)
  return if w < 1
  w.times do |i|
    Termbox2.set_cell(x + i, y, 0x20, 0, color_fn.call(i, w))
  end
end

# ── event description helpers ─────────────────────────────────────────────

KEY_NAMES = {
  Termbox2::KEY_F1          => "F1",
  Termbox2::KEY_F2          => "F2",
  Termbox2::KEY_F3          => "F3",
  Termbox2::KEY_F4          => "F4",
  Termbox2::KEY_F5          => "F5",
  Termbox2::KEY_F6          => "F6",
  Termbox2::KEY_F7          => "F7",
  Termbox2::KEY_F8          => "F8",
  Termbox2::KEY_F9          => "F9",
  Termbox2::KEY_F10         => "F10",
  Termbox2::KEY_F11         => "F11",
  Termbox2::KEY_F12         => "F12",
  Termbox2::KEY_INSERT      => "INSERT",
  Termbox2::KEY_DELETE      => "DELETE",
  Termbox2::KEY_HOME        => "HOME",
  Termbox2::KEY_END         => "END",
  Termbox2::KEY_PGUP        => "PGUP",
  Termbox2::KEY_PGDN        => "PGDN",
  Termbox2::KEY_ARROW_UP    => "UP",
  Termbox2::KEY_ARROW_DOWN  => "DOWN",
  Termbox2::KEY_ARROW_LEFT  => "LEFT",
  Termbox2::KEY_ARROW_RIGHT => "RIGHT",
  Termbox2::KEY_BACK_TAB    => "BACK_TAB",
  Termbox2::KEY_ESC         => "ESC",
  Termbox2::KEY_ENTER       => "ENTER",
  Termbox2::KEY_TAB         => "TAB",
  Termbox2::KEY_BACKSPACE   => "BACKSPACE",
  Termbox2::KEY_BACKSPACE2  => "DEL",
  Termbox2::KEY_SPACE       => "SPACE",
  Termbox2::KEY_CTRL_A      => "CTRL-A",
  Termbox2::KEY_CTRL_B      => "CTRL-B",
  Termbox2::KEY_CTRL_C      => "CTRL-C",
  Termbox2::KEY_CTRL_D      => "CTRL-D",
  Termbox2::KEY_CTRL_L      => "CTRL-L",
  Termbox2::KEY_CTRL_U      => "CTRL-U",
  Termbox2::KEY_CTRL_W      => "CTRL-W",
}

MOUSE_NAMES = {
  Termbox2::KEY_MOUSE_LEFT       => "LEFT",
  Termbox2::KEY_MOUSE_RIGHT      => "RIGHT",
  Termbox2::KEY_MOUSE_MIDDLE     => "MIDDLE",
  Termbox2::KEY_MOUSE_RELEASE    => "RELEASE",
  Termbox2::KEY_MOUSE_WHEEL_UP   => "WHEEL-UP",
  Termbox2::KEY_MOUSE_WHEEL_DOWN => "WHEEL-DOWN",
}

def key_name(key)
  KEY_NAMES[key] || sprintf("0x%04X", key)
end

def mouse_name(key)
  MOUSE_NAMES[key] || sprintf("0x%04X", key)
end

def mod_str(mod)
  parts = []
  parts << "ALT"   if (mod & Termbox2::MOD_ALT)   != 0
  parts << "CTRL"  if (mod & Termbox2::MOD_CTRL)  != 0
  parts << "SHIFT" if (mod & Termbox2::MOD_SHIFT) != 0
  parts.empty? ? "-" : parts.join("+")
end

def record_event(ev)
  desc = case ev.type
  when Termbox2::EVENT_KEY
    if ev.ch > 0
      sprintf("KEY    ch=U+%04X (%c)          mod=%s", ev.ch, ev.ch, mod_str(ev.mod))
    else
      sprintf("KEY    %-20s           mod=%s", key_name(ev.key), mod_str(ev.mod))
    end
  when Termbox2::EVENT_RESIZE
    sprintf("RESIZE %dx%d", ev.w, ev.h)
  when Termbox2::EVENT_MOUSE
    sprintf("MOUSE  (%3d,%3d) %-12s mod=%s", ev.x, ev.y, mouse_name(ev.key), mod_str(ev.mod))
  else
    sprintf("type=%d", ev.type)
  end
  $events.unshift(desc)
  $events.pop if $events.length > 30
end

# ── output mode management ────────────────────────────────────────────────

def page_output_mode(p)
  case p
  when 1 then Termbox2::OUTPUT_256
  when 2 then Termbox2.has_truecolor? ? Termbox2::OUTPUT_TRUECOLOR : Termbox2::OUTPUT_256
  else        Termbox2::OUTPUT_NORMAL
  end
end

def set_page_mode(p)
  Termbox2.set_output_mode(page_output_mode(p))
end

# ── chrome: header + status bar ───────────────────────────────────────────

def draw_header
  w  = Termbox2.width
  bg = Termbox2::BLUE
  hline(0, Termbox2::WHITE, bg)
  Termbox2.print(1, 0, Termbox2::WHITE | Termbox2::BOLD, bg, "mruby-termbox2 demo")
  nav = "<- -> page  m mouse  q quit"
  sz  = sprintf("%dx%d", w, Termbox2.height)
  Termbox2.print(w - nav.length - 1, 0, Termbox2::YELLOW, bg, nav)
  Termbox2.print(w - nav.length - sz.length - 3, 0, Termbox2::CYAN, bg, sz)

  x = 0
  PAGES.each_with_index do |name, i|
    label = "  #{name}  "
    if i == $page
      Termbox2.print(x, 1, Termbox2::BLACK | Termbox2::BOLD, Termbox2::WHITE, label)
    else
      Termbox2.print(x, 1, Termbox2::DEFAULT, Termbox2::DEFAULT, label)
    end
    x += label.length
    Termbox2.set_cell(x, 1, 0x7C, Termbox2::DEFAULT, Termbox2::DEFAULT)  # |
    x += 1
  end
end

def draw_status_bar
  w = Termbox2.width
  h = Termbox2.height
  hline(h - 1, Termbox2::DEFAULT, Termbox2::DEFAULT)
  mouse_info = $mouse_on ? sprintf("mouse:ON  (%d,%d)", $mouse_x, $mouse_y) : "mouse:OFF"
  left  = " #{mouse_info}"
  right = sprintf("termbox2 %s  attr_w=%d ", Termbox2.version, Termbox2.attr_width)
  Termbox2.print(0,              h - 1, Termbox2::DEFAULT, Termbox2::DEFAULT, left)
  Termbox2.print(w - right.length, h - 1, Termbox2::DEFAULT, Termbox2::DEFAULT, right)
end

# ── page 0: basic colors ─────────────────────────────────────────────────

def draw_basic_colors_page
  w = Termbox2.width
  y = 3

  # Foreground & background color swatches side by side
  Termbox2.print(0,  y, Termbox2::WHITE | Termbox2::BOLD, Termbox2::DEFAULT, " Foreground        Background ")
  y += 1

  NAMED_COLORS.each do |color, name|
    label = sprintf("%-8s", name)
    # Foreground: color on default bg, sample text
    Termbox2.print(1,  y, color, Termbox2::DEFAULT, "#{label}  The quick brown fox")
    # Background: white text on color
    Termbox2.print(32, y, Termbox2::WHITE, color, "  #{label}  ")
    y += 1
  end

  y += 1

  # Attribute showcase — flow across columns
  Termbox2.print(0, y, Termbox2::WHITE | Termbox2::BOLD, Termbox2::DEFAULT, " Text Attributes ")
  y += 1
  x = 1
  NAMED_ATTRS.each do |attr, name|
    label = " #{name} "
    if x + label.length > w - 1
      x = 1
      y += 1
    end
    Termbox2.print(x, y, Termbox2::WHITE | attr, Termbox2::DEFAULT, label)
    x += label.length + 1
  end

  y += 2

  # Combined fg + bg + attr examples
  return if y >= Termbox2.height - 3
  Termbox2.print(0, y, Termbox2::WHITE | Termbox2::BOLD, Termbox2::DEFAULT, " Combinations ")
  y += 1
  x = 1

  combos = [
    [Termbox2::WHITE,   Termbox2::BOLD,                              Termbox2::RED,     "White+Bold on Red"],
    [Termbox2::BLACK,   0,                                           Termbox2::YELLOW,  "Black on Yellow"],
    [Termbox2::YELLOW,  Termbox2::BOLD | Termbox2::UNDERLINE,        Termbox2::BLUE,    "Yellow+Bold+Uline on Blue"],
    [Termbox2::CYAN,    Termbox2::ITALIC,                            Termbox2::MAGENTA, "Cyan+Italic on Magenta"],
    [Termbox2::GREEN,   Termbox2::BOLD | Termbox2::REVERSE,          Termbox2::DEFAULT, "Green+Bold+Reverse"],
    [Termbox2::WHITE,   Termbox2::BLINK,                             Termbox2::RED,     "White+Blink on Red"],
    [Termbox2::BLUE,    Termbox2::BOLD | Termbox2::ITALIC | Termbox2::UNDERLINE, Termbox2::WHITE, "Blue+Bold+Italic+Uline on White"],
    [Termbox2::RED,     Termbox2::DIM,                               Termbox2::DEFAULT, "Red+Dim"],
    [Termbox2::WHITE,   Termbox2::BRIGHT,                            Termbox2::DEFAULT, "White+Bright"],
  ]
  combos.each do |fg, attr, bg, label|
    cell = " #{label} "
    if x + cell.length > w - 1
      x = 1
      y += 1
      break if y >= Termbox2.height - 2
    end
    Termbox2.print(x, y, fg | attr, bg, cell)
    x += cell.length + 1
  end
end

# ── page 1: 256 colors ───────────────────────────────────────────────────

def draw_256_colors_page
  w = Termbox2.width
  y = 3

  Termbox2.print(0, y, Termbox2::WHITE | Termbox2::BOLD, Termbox2::DEFAULT,
                 " 256-Color Palette (OUTPUT_256) ")
  y += 2

  # System 16
  Termbox2.print(0, y, Termbox2::WHITE, Termbox2::DEFAULT, "System 16 (0-15):")
  y += 1
  x = 2
  16.times do |i|
    3.times { |dx| Termbox2.set_cell(x + dx, y, 0x20, 0, i) }
    Termbox2.print(x, y + 1, Termbox2::WHITE, Termbox2::DEFAULT, sprintf("%-3d", i))
    x += 4
  end
  y += 3

  return if y >= Termbox2.height - 3

  # 6x6x6 colour cube (16-231)
  Termbox2.print(0, y, Termbox2::WHITE, Termbox2::DEFAULT, "6x6x6 Color Cube (16-231):")
  y += 1
  per_row = [(w - 2) / 2, 36].min
  per_row = 1 if per_row < 1
  (0..215).each do |i|
    cx = 2 + (i % per_row) * 2
    cy = y + i / per_row
    Termbox2.set_cell(cx,     cy, 0x20, 0, 16 + i)
    Termbox2.set_cell(cx + 1, cy, 0x20, 0, 16 + i)
  end
  y += (215 / per_row) + 2

  return if y >= Termbox2.height - 3

  # Grayscale ramp (232-255)
  Termbox2.print(0, y, Termbox2::WHITE, Termbox2::DEFAULT, "Grayscale (232-255):")
  y += 1
  x = 2
  (232..255).each do |i|
    Termbox2.set_cell(x,     y, 0x20, 0, i)
    Termbox2.set_cell(x + 1, y, 0x20, 0, i)
    x += 2
  end
end

# ── page 2: truecolor ────────────────────────────────────────────────────

def draw_truecolor_page
  w         = Termbox2.width
  y         = 3
  available = Termbox2.has_truecolor?
  bar_w     = [w - 12, 4].max

  unless available
    Termbox2.print(2, y,     Termbox2::YELLOW | Termbox2::BOLD, Termbox2::DEFAULT,
                   "Truecolor unavailable on this terminal.")
    Termbox2.print(2, y + 1, Termbox2::DEFAULT, Termbox2::DEFAULT,
                   "Showing 256-color mode. Compile with a truecolor terminal for this page.")
    return
  end

  Termbox2.print(0, y, Termbox2::WHITE | Termbox2::BOLD, Termbox2::DEFAULT,
                 " Truecolor (24-bit RGB, OUTPUT_TRUECOLOR) ")
  y += 2

  bars = [
    ["Rainbow   ", ->(i, w) { hsv_rgb(i * 360.0 / w, 1.0, 1.0) }],
    ["Red       ", ->(i, w) { ((i * 255 / (w - 1)) << 16) }],
    ["Green     ", ->(i, w) { ((i * 255 / (w - 1)) << 8) }],
    ["Blue      ", ->(i, w) { (i * 255 / (w - 1)) }],
    ["White     ", ->(i, w) { v = i * 255 / (w - 1); (v << 16) | (v << 8) | v }],
    ["Hue+Sat   ", ->(i, w) { hsv_rgb(i * 360.0 / w, i.to_f / (w - 1), 1.0) }],
    ["Pastel    ", ->(i, w) { hsv_rgb(i * 360.0 / w, 0.4, 1.0) }],
  ]

  bars.each do |label, fn|
    break if y >= Termbox2.height - 4
    Termbox2.print(0, y, Termbox2::WHITE, Termbox2::DEFAULT, label)
    gradient_bar(10, y, bar_w, fn)
    y += 2
  end

  return if y >= Termbox2.height - 4

  # Named 24-bit color swatches
  Termbox2.print(0, y, Termbox2::WHITE | Termbox2::BOLD, Termbox2::DEFAULT, " Named 24-bit Colors ")
  y += 1
  swatches = [
    [0xFF6B6B, "Coral"],     [0x4ECDC4, "Turquoise"],  [0x45B7D1, "Sky"],
    [0xA8E6CF, "Mint"],      [0xFFD93D, "Gold"],        [0xC3B1E1, "Lavender"],
    [0xFF8C69, "Salmon"],    [0x98D8C8, "Seafoam"],     [0xF7B2BD, "Rose"],
    [0x6BCB77, "Grass"],     [0x4D96FF, "Cornflower"],  [0xFFD166, "Amber"],
    [0xEF476F, "Crimson"],   [0x06D6A0, "Emerald"],     [0x118AB2, "Cerulean"],
    [0x073B4C, "Midnight"],  [0xFFF275, "Butter"],      [0xF4A261, "Sandstone"],
  ]
  x = 2
  swatches.each do |color, name|
    swatch = "   "
    label  = " #{name} "
    total  = swatch.length + label.length + 1
    if x + total > w - 1
      x = 2
      y += 2
      break if y >= Termbox2.height - 2
    end
    Termbox2.print(x, y, 0, color, swatch)
    Termbox2.print(x + swatch.length, y, color, Termbox2::DEFAULT, label)
    x += total
  end
end

# ── page 3: event log ────────────────────────────────────────────────────

def draw_events_page
  w = Termbox2.width
  h = Termbox2.height
  y = 3

  mouse_label = $mouse_on ? "mouse: ON  [m] to disable" : "mouse: OFF [m] to enable"
  Termbox2.print(0, y, Termbox2::WHITE | Termbox2::BOLD, Termbox2::DEFAULT, " Event Log ")
  Termbox2.print(w - mouse_label.length - 1, y, Termbox2::CYAN, Termbox2::DEFAULT, mouse_label)
  y += 1

  # Column header
  header = sprintf("%-4s  %-s", " # ", "Event")
  Termbox2.print(0, y, Termbox2::WHITE | Termbox2::UNDERLINE, Termbox2::DEFAULT,
                 sprintf("%-#{w}s", header))
  y += 1

  max_rows = h - y - 2
  if $events.empty?
    Termbox2.print(2, y + 1, Termbox2::DEFAULT, Termbox2::DEFAULT,
                   "No events yet. Press keys, resize, or enable mouse.")
  else
    [$events.length, max_rows].min.times do |i|
      row_fg = i == 0 ? Termbox2::WHITE | Termbox2::BOLD : Termbox2::DEFAULT
      Termbox2.print(0, y + i, Termbox2::YELLOW,  Termbox2::DEFAULT, sprintf("%3d", i + 1))
      Termbox2.print(3, y + i, Termbox2::DEFAULT, Termbox2::DEFAULT, "  ")
      Termbox2.print(5, y + i, row_fg,            Termbox2::DEFAULT, $events[i])
    end
  end
end

# ── top-level draw ────────────────────────────────────────────────────────

def draw
  Termbox2.clear
  draw_header
  case $page
  when 0 then draw_basic_colors_page
  when 1 then draw_256_colors_page
  when 2 then draw_truecolor_page
  when 3 then draw_events_page
  end
  draw_status_bar
  Termbox2.present
end

def toggle_mouse
  $mouse_on = !$mouse_on
  mode = $mouse_on ? Termbox2::INPUT_ESC | Termbox2::INPUT_MOUSE : Termbox2::INPUT_ESC
  Termbox2.set_input_mode(mode)
end

def goto_page(p)
  $page = p % PAGES.length
  set_page_mode($page)
end

# ── main event loop ───────────────────────────────────────────────────────

Termbox2.with_init do
  set_page_mode($page)
  Termbox2.set_input_mode(Termbox2::INPUT_ESC)
  Termbox2.hide_cursor
  draw

  loop do
    ev = Termbox2.poll_event
    next unless ev

    case ev.type
    when Termbox2::EVENT_KEY
      record_event(ev)

      case ev.key
      when Termbox2::KEY_ARROW_LEFT  then goto_page($page - 1)
      when Termbox2::KEY_ARROW_RIGHT then goto_page($page + 1)
      end

      case ev.ch
      when "q".ord                               then break
      when "h".ord                               then goto_page($page - 1)
      when "l".ord                               then goto_page($page + 1)
      when "m".ord                               then toggle_mouse
      when "1".ord, "2".ord, "3".ord, "4".ord   then goto_page(ev.ch - "1".ord)
      end

    when Termbox2::EVENT_RESIZE
      record_event(ev)

    when Termbox2::EVENT_MOUSE
      $mouse_x = ev.x
      $mouse_y = ev.y
      record_event(ev)
    end

    draw
  end
end
