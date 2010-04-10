module MyScripts
  # Base class for all scripts. Subclass it and override run method with actual
  # work your script will be doing
  class Script
    def initialize( name, argv, cli )
      @name = name
      @argv = argv
      @cli = cli
    end

    def version
      if self.class.const_defined? :VERSION
        self.class::VERSION  # Script's own version
      else
        VERSION # Gem version
      end
    end

    def run
    end

    def puts *args
      @cli.stdout.puts *args
      nil
    end

    def gets
      @cli.stdin.gets
    end

    def usage examples, explanation = nil
      puts "Script #{@name} #{version} - Usage:"
      (examples.respond_to?(:split) ? examples.split("\n") : examples).map {|line| puts "    #{@name} #{line}"}
      puts explanation if explanation
      exit 1
    end

    def to_s
      "#{@name} #{@argv.join(' ')} -> #{self.class}"
    end
  end
end
