module MyScripts
  # Dummy script skeleton that is ready for your usage. Just put your script code
  # inside run method (if you use ARGV, change it to @argv). Done!
  # You can immediately run your script anywhere using following command:
  #   $ dummy Whatever arguments your code expects and processes
  #
  class Dummy < Script
    def run
      # here you do all actual work for your script
      # you have following instance vars at your disposal:
      # @name - your script name,
      # @argv - your ARGV (Array of argument Strings passed at command line),
      # @cli - CLI runner (holds references to stdin and stdout)
      #...
    end
  end
end
