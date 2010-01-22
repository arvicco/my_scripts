module MyScripts
  class Script # Base class for all scripts
    def initialize( name, argv, cli )
      @name = name
      @argv = argv
      @cli = cli
    end

    def puts *args
      @cli.stdout.puts *args
    end

    def usage examples, explanation = nil
      puts "Usage:"
      puts examples.split("\n").map {|line| "    #{@name} #{line}"}
      puts explanation if explanation
      exit 1
    end
  end
end
