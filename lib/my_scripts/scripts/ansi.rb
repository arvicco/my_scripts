module MyScripts
  # This script should be used as a pipe to colorize ANSI output on Windows
  # Use case is like this (provides colorized autotest output):
  #
  # > autotest | ansi
  #
  class Ansi < Script
    VERSION = '0.0.1'

    def initialize(name, cli, argv, argf)
      require 'win32console'
      @cli = cli
      @io = Win32::Console::ANSI::IO.new()
      super
    end

    def run
      Signal.trap('INT') do
        @io.puts "ANSI Got Interrupt"
        @io.flush
        exit
      end

      until @cli.stdin.eof? do
        line = @cli.stdin.gets
        @io.puts line
      end
      @io.flush
    end
  end
end