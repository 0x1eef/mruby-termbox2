module Termbox2
  def self.with_init
    init
    begin
      yield
    ensure
      shutdown
    end
  end

  class Event
    def key_event?
      type == Termbox2::EVENT_KEY
    end

    def resize_event?
      type == Termbox2::EVENT_RESIZE
    end

    def mouse_event?
      type == Termbox2::EVENT_MOUSE
    end

    def inspect
      "#<Termbox2::Event type=#{type} mod=#{mod} key=#{key} ch=#{ch} w=#{w} h=#{h} x=#{x} y=#{y}>"
    end
  end
end
