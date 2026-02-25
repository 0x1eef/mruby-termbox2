# mruby-termbox2

MRuby bindings for [termbox2](https://github.com/termbox/termbox2), a minimal terminal I/O library.

## Installation

Add to your `build_config.rb`:

```ruby
conf.gem github: 'pusewicz/mruby-termbox2'
```

Or with a local path:

```ruby
conf.gem '/path/to/mruby-termbox2'
```

## Usage

```ruby
Termbox2.with_init do
  Termbox2.set_clear_attrs(Termbox2::DEFAULT, Termbox2::DEFAULT)
  Termbox2.clear
  Termbox2.print(0, 0, Termbox2::WHITE, Termbox2::DEFAULT, "Hello, terminal!")
  Termbox2.present

  event = Termbox2.poll_event
  if event.key_event?
    # handle key
  end
end
```

## API

### Module Methods

| Method | Description |
|---|---|
| `Termbox2.init` | Initialize the library |
| `Termbox2.init_file(path)` | Initialize with a tty path |
| `Termbox2.init_fd(fd)` | Initialize with a file descriptor |
| `Termbox2.init_rwfd(rfd, wfd)` | Initialize with separate read/write fds |
| `Termbox2.shutdown` | Shutdown the library |
| `Termbox2.width` | Terminal width in columns |
| `Termbox2.height` | Terminal height in rows |
| `Termbox2.clear` | Clear the back buffer |
| `Termbox2.set_clear_attrs(fg, bg)` | Set clear attributes |
| `Termbox2.present` | Flush back buffer to terminal |
| `Termbox2.invalidate` | Force full re-render |
| `Termbox2.set_cursor(x, y)` | Set cursor position |
| `Termbox2.hide_cursor` | Hide the cursor |
| `Termbox2.set_cell(x, y, ch, fg, bg)` | Set a cell |
| `Termbox2.extend_cell(x, y, ch)` | Extend a cell with codepoint |
| `Termbox2.set_input_mode(mode)` | Set input mode |
| `Termbox2.set_output_mode(mode)` | Set output mode |
| `Termbox2.poll_event` | Block until an event, returns `Event` |
| `Termbox2.peek_event(timeout_ms)` | Check for event with timeout, returns `Event` or `nil` |
| `Termbox2.print(x, y, fg, bg, str)` | Print a string |
| `Termbox2.last_errno` | Last errno value |
| `Termbox2.strerror(err)` | Error string for error code |
| `Termbox2.has_truecolor?` | True if truecolor is supported |
| `Termbox2.has_egc?` | True if EGC is supported |
| `Termbox2.attr_width` | Attribute width in bits |
| `Termbox2.version` | Library version string |
| `Termbox2.with_init { }` | Initialize, yield, ensure shutdown |

### Event

```ruby
event = Termbox2.poll_event
event.type   # TB_EVENT_KEY, TB_EVENT_RESIZE, TB_EVENT_MOUSE
event.mod    # modifier flags (TB_MOD_*)
event.key    # key code (TB_KEY_*)
event.ch     # Unicode codepoint
event.w      # resize width
event.h      # resize height
event.x      # mouse x
event.y      # mouse y

event.key_event?    # true if TB_EVENT_KEY
event.resize_event? # true if TB_EVENT_RESIZE
event.mouse_event?  # true if TB_EVENT_MOUSE
```

### Constants

Colors: `DEFAULT`, `BLACK`, `RED`, `GREEN`, `YELLOW`, `BLUE`, `MAGENTA`, `CYAN`, `WHITE`

Attributes: `BOLD`, `UNDERLINE`, `REVERSE`, `ITALIC`, `BLINK`, `HI_BLACK`, `BRIGHT`, `DIM`

Event types: `EVENT_KEY`, `EVENT_RESIZE`, `EVENT_MOUSE`

Input modes: `INPUT_CURRENT`, `INPUT_ESC`, `INPUT_ALT`, `INPUT_MOUSE`

Output modes: `OUTPUT_CURRENT`, `OUTPUT_NORMAL`, `OUTPUT_256`, `OUTPUT_216`, `OUTPUT_GRAYSCALE`, `OUTPUT_TRUECOLOR`

Modifiers: `MOD_ALT`, `MOD_CTRL`, `MOD_SHIFT`, `MOD_MOTION`

## License

MIT. See [LICENSE](LICENSE).

termbox2 is MIT licensed. See [lib/termbox2/termbox2.h](lib/termbox2/termbox2.h).
