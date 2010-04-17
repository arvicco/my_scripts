module MyScripts
  # This class encapsulates Command Line Interface for running scripts. It can be instantiated
  # with stubbed stdin and stdout if you want to run tests on your scripts
  class CLI
    class ScriptNameError < NameError  # :nodoc:
      def initialize(message=nil)
        message ? super(message) : super
      end
    end

    attr_accessor :stdout, :stdin, :kernel

    # Instantiates new CLI(command line interface) and runs script with given name (token)
    # and argv inside new CLI instance
    def self.run( script_name, argv, argf=ARGF )
      new.run script_name, argv, argf
    end

    # Creates new command line interface
    def initialize( stdin=$stdin, stdout=$stdout, kernel = Kernel )
      @stdin = stdin
      @stdout = stdout
      @kernel = kernel
    end

    # Runs a script with given name (token) and argv inside this CLI instance
    def run( script_name, argv, argf=ARGF )
      script = script_class_name(script_name).to_class
      raise ScriptNameError.new("Script #{script_class_name(script_name)} not found") unless script
      
      script.new(script_name, self, argv, argf).run
    end

    private

    def script_class_name(script_name)
      "MyScripts::#{script_name.to_s.camel_case}"
    end
  end
end
