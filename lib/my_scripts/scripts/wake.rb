module MyScripts
  # This script prevents screen saver from locking down Windows by randomly moving
  # mouse pointer a bit every 4 minutes or so. Why would you need this? Well, if your
  # XP box is in a domain with security-crazy admins who have immutable policy of
  # forced screen saver after 5 minutes of inactivity you'd feel the pain...
  #
  class Wake < Script
    VERSION = '0.1.0'

    SLEEP_TIME = 4 * 60 # seconds

    def initialize( name, cli, argv, argf )
      require 'win/gui/input'
      require 'win/error'
      self.class.send(:include, Win::Gui::Input)
      super
    end

    def move_mouse_randomly
      x, y = get_cursor_pos

      # For some reason, x or y returns as nil sometimes
      if x && y
        x1, y1 = x + rand(3) - 1, y + rand(3) - 1
        mouse_event(MOUSEEVENTF_ABSOLUTE, x1, y1, 0, 0)
        puts "Cursor positon set to #{x1}, #{y1}"
      else
        puts "X: #{x}, Y: #{y}, last error: #{Win::Error::get_last_error}"
      end
    end

    def run
      case @argv.size
        when 0
          sleep_time = SLEEP_TIME
        when 1
          sleep_time = @argv.first.to_f * 60
        else
          usage "[minutes] - prevents screen auto lock-up by moving mouse pointer every [(4) minutes]"
      end

      loop do
        move_mouse_randomly
        sleep sleep_time
      end
    end
  end
end