# Tests for mruby-termbox2
# These tests run without a real terminal (no /dev/tty required).

assert("Termbox2 module exists") do
  assert_true defined?(Termbox2)
  assert_true Termbox2.is_a?(Module)
end

assert("Termbox2::Error class exists") do
  assert_true defined?(Termbox2::Error)
  assert_true Termbox2::Error.ancestors.include?(RuntimeError)
end

assert("Termbox2::Event class exists") do
  assert_true defined?(Termbox2::Event)
  assert_true Termbox2::Event.is_a?(Class)
end

assert("Termbox2 responds to module functions") do
  assert_true Termbox2.respond_to?(:init)
  assert_true Termbox2.respond_to?(:init_file)
  assert_true Termbox2.respond_to?(:init_fd)
  assert_true Termbox2.respond_to?(:init_rwfd)
  assert_true Termbox2.respond_to?(:shutdown)
  assert_true Termbox2.respond_to?(:width)
  assert_true Termbox2.respond_to?(:height)
  assert_true Termbox2.respond_to?(:clear)
  assert_true Termbox2.respond_to?(:set_clear_attrs)
  assert_true Termbox2.respond_to?(:present)
  assert_true Termbox2.respond_to?(:invalidate)
  assert_true Termbox2.respond_to?(:set_cursor)
  assert_true Termbox2.respond_to?(:hide_cursor)
  assert_true Termbox2.respond_to?(:set_cell)
  assert_true Termbox2.respond_to?(:extend_cell)
  assert_true Termbox2.respond_to?(:set_input_mode)
  assert_true Termbox2.respond_to?(:set_output_mode)
  assert_true Termbox2.respond_to?(:poll_event)
  assert_true Termbox2.respond_to?(:peek_event)
  assert_true Termbox2.respond_to?(:print)
  assert_true Termbox2.respond_to?(:last_errno)
  assert_true Termbox2.respond_to?(:strerror)
  assert_true Termbox2.respond_to?(:"has_truecolor?")
  assert_true Termbox2.respond_to?(:"has_egc?")
  assert_true Termbox2.respond_to?(:attr_width)
  assert_true Termbox2.respond_to?(:version)
  assert_true Termbox2.respond_to?(:with_init)
end

assert("Termbox2::Event has instance methods") do
  assert_true Termbox2::Event.method_defined?(:type)
  assert_true Termbox2::Event.method_defined?(:mod)
  assert_true Termbox2::Event.method_defined?(:key)
  assert_true Termbox2::Event.method_defined?(:ch)
  assert_true Termbox2::Event.method_defined?(:w)
  assert_true Termbox2::Event.method_defined?(:h)
  assert_true Termbox2::Event.method_defined?(:x)
  assert_true Termbox2::Event.method_defined?(:y)
  assert_true Termbox2::Event.method_defined?(:key_event?)
  assert_true Termbox2::Event.method_defined?(:resize_event?)
  assert_true Termbox2::Event.method_defined?(:mouse_event?)
  assert_true Termbox2::Event.method_defined?(:inspect)
end

assert("color constants have correct values") do
  assert_equal 0x0000, Termbox2::DEFAULT
  assert_equal 0x0001, Termbox2::BLACK
  assert_equal 0x0002, Termbox2::RED
  assert_equal 0x0003, Termbox2::GREEN
  assert_equal 0x0004, Termbox2::YELLOW
  assert_equal 0x0005, Termbox2::BLUE
  assert_equal 0x0006, Termbox2::MAGENTA
  assert_equal 0x0007, Termbox2::CYAN
  assert_equal 0x0008, Termbox2::WHITE
end

assert("attribute constants have correct values (TB_OPT_ATTR_W=32)") do
  assert_equal 0x01000000, Termbox2::BOLD
  assert_equal 0x02000000, Termbox2::UNDERLINE
  assert_equal 0x04000000, Termbox2::REVERSE
  assert_equal 0x08000000, Termbox2::ITALIC
  assert_equal 0x10000000, Termbox2::BLINK
  assert_equal 0x20000000, Termbox2::HI_BLACK
  assert_equal 0x40000000, Termbox2::BRIGHT
end

assert("event type constants have correct values") do
  assert_equal 1, Termbox2::EVENT_KEY
  assert_equal 2, Termbox2::EVENT_RESIZE
  assert_equal 3, Termbox2::EVENT_MOUSE
end

assert("modifier constants have correct values") do
  assert_equal 1, Termbox2::MOD_ALT
  assert_equal 2, Termbox2::MOD_CTRL
  assert_equal 4, Termbox2::MOD_SHIFT
  assert_equal 8, Termbox2::MOD_MOTION
end

assert("input mode constants have correct values") do
  assert_equal 0, Termbox2::INPUT_CURRENT
  assert_equal 1, Termbox2::INPUT_ESC
  assert_equal 2, Termbox2::INPUT_ALT
  assert_equal 4, Termbox2::INPUT_MOUSE
end

assert("output mode constants have correct values") do
  assert_equal 0, Termbox2::OUTPUT_CURRENT
  assert_equal 1, Termbox2::OUTPUT_NORMAL
  assert_equal 2, Termbox2::OUTPUT_256
  assert_equal 3, Termbox2::OUTPUT_216
  assert_equal 4, Termbox2::OUTPUT_GRAYSCALE
  assert_equal 5, Termbox2::OUTPUT_TRUECOLOR
end

assert("error code constants have correct values") do
  assert_equal  0,   Termbox2::OK
  assert_equal(-1,   Termbox2::ERR)
  assert_equal(-2,   Termbox2::ERR_NEED_MORE)
  assert_equal(-3,   Termbox2::ERR_INIT_ALREADY)
  assert_equal(-4,   Termbox2::ERR_INIT_OPEN)
  assert_equal(-5,   Termbox2::ERR_MEM)
  assert_equal(-6,   Termbox2::ERR_NO_EVENT)
  assert_equal(-7,   Termbox2::ERR_NO_TERM)
  assert_equal(-8,   Termbox2::ERR_NOT_INIT)
  assert_equal(-9,   Termbox2::ERR_OUT_OF_BOUNDS)
  assert_equal(-10,  Termbox2::ERR_READ)
  assert_equal(-11,  Termbox2::ERR_RESIZE_IOCTL)
  assert_equal(-12,  Termbox2::ERR_RESIZE_PIPE)
  assert_equal(-13,  Termbox2::ERR_RESIZE_SIGACTION)
  assert_equal(-14,  Termbox2::ERR_POLL)
  assert_equal(-15,  Termbox2::ERR_TCGETATTR)
  assert_equal(-16,  Termbox2::ERR_TCSETATTR)
  assert_equal(-17,  Termbox2::ERR_UNSUPPORTED_TERM)
  assert_equal(-18,  Termbox2::ERR_RESIZE_WRITE)
  assert_equal(-19,  Termbox2::ERR_RESIZE_POLL)
  assert_equal(-20,  Termbox2::ERR_RESIZE_READ)
  assert_equal(-21,  Termbox2::ERR_RESIZE_SSCANF)
  assert_equal(-22,  Termbox2::ERR_CAP_COLLISION)
end

assert("key constants have correct values") do
  assert_equal 0x00, Termbox2::KEY_CTRL_TILDE
  assert_equal 0x01, Termbox2::KEY_CTRL_A
  assert_equal 0x03, Termbox2::KEY_CTRL_C
  assert_equal 0x08, Termbox2::KEY_BACKSPACE
  assert_equal 0x09, Termbox2::KEY_TAB
  assert_equal 0x0d, Termbox2::KEY_ENTER
  assert_equal 0x1b, Termbox2::KEY_ESC
  assert_equal 0x20, Termbox2::KEY_SPACE
  assert_equal 0x7f, Termbox2::KEY_BACKSPACE2
  assert_equal 0xffff, Termbox2::KEY_F1
  assert_equal 0xffff - 1,  Termbox2::KEY_F2
  assert_equal 0xffff - 18, Termbox2::KEY_ARROW_UP
  assert_equal 0xffff - 19, Termbox2::KEY_ARROW_DOWN
  assert_equal 0xffff - 20, Termbox2::KEY_ARROW_LEFT
  assert_equal 0xffff - 21, Termbox2::KEY_ARROW_RIGHT
end

assert("version returns a non-empty string") do
  v = Termbox2.version
  assert_true v.is_a?(String)
  assert_true v.length > 0
end

assert("strerror returns a string") do
  s = Termbox2.strerror(Termbox2::ERR_NOT_INIT)
  assert_true s.is_a?(String)
  assert_true s.length > 0
end

assert("strerror for OK returns a string") do
  s = Termbox2.strerror(Termbox2::OK)
  assert_true s.is_a?(String)
end

assert("attr_width returns 32") do
  assert_equal 32, Termbox2.attr_width
end

assert("has_truecolor? returns true or false") do
  result = Termbox2.has_truecolor?
  assert_true result == true || result == false
end

assert("has_egc? returns true or false") do
  result = Termbox2.has_egc?
  assert_true result == true || result == false
end

assert("width raises Termbox2::Error when not initialized") do
  assert_raise(Termbox2::Error) { Termbox2.width }
end

assert("height raises Termbox2::Error when not initialized") do
  assert_raise(Termbox2::Error) { Termbox2.height }
end

assert("clear raises Termbox2::Error when not initialized") do
  assert_raise(Termbox2::Error) { Termbox2.clear }
end

assert("present raises Termbox2::Error when not initialized") do
  assert_raise(Termbox2::Error) { Termbox2.present }
end

assert("set_cursor raises Termbox2::Error when not initialized") do
  assert_raise(Termbox2::Error) { Termbox2.set_cursor(0, 0) }
end

assert("set_cell raises Termbox2::Error when not initialized") do
  assert_raise(Termbox2::Error) { Termbox2.set_cell(0, 0, 0x40, Termbox2::DEFAULT, Termbox2::DEFAULT) }
end

assert("print raises Termbox2::Error when not initialized") do
  assert_raise(Termbox2::Error) { Termbox2.print(0, 0, Termbox2::DEFAULT, Termbox2::DEFAULT, "hi") }
end

assert("set_input_mode raises Termbox2::Error when not initialized") do
  assert_raise(Termbox2::Error) { Termbox2.set_input_mode(Termbox2::INPUT_ESC) }
end

assert("set_output_mode raises Termbox2::Error when not initialized") do
  assert_raise(Termbox2::Error) { Termbox2.set_output_mode(Termbox2::OUTPUT_NORMAL) }
end
