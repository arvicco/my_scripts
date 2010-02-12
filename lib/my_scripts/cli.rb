module MyScripts
  # This class encapsulates Command Line Interface for running scripts. It can be instantiated
  # with stubbed stdin and stdout if you want to run tests on your scripts
  class CLI

    attr_accessor :stdout, :stdin

    # Instantiates new CLI(command line interface) and runs script with given name (token)
    # and argv inside new CLI instance
    def self.run( script_name, argv )
      new.run script_name, argv
    end

    # Creates new command line interface
    def initialize( stdin=$stdin, stdout=$stdout )
      @stdin = stdin
      @stdout = stdout
    end

    # Runs a script with given name (token) and argv inside this CLI instance
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
