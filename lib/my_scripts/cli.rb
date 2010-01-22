module MyScripts
  class CLI

    attr_accessor :stdout, :stdin

    def self.run( script_name, argv )
      new.run script_name, argv
    end

    def initialize( stdin=$stdin, stdout=$stdout )
      @stdin = stdin
      @stdout = stdout
    end

    def run( script_name, argv )
      script = "MyScripts::#{script_name.capitalize}".to_class
      script.new(script_name, argv, self).run
    rescue => e
      @stdout.puts e.backtrace
      @stdout.puts e.message
      exit 1
    end
  end
end
