require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

module MyScriptsTest

  # creates new CLI object with mock stdin and stdout,
  # stdin optionally preloaded with fake user input
  def create_cli( opts={} )
    @stdout = options[:stdout] || mock('stdout').as_null_object
    @stdin = options[:stdin] || mock('stdin')
    @stdin.stub(:gets).and_return(*options[:input]) if options[:input]
    @cli = MyScripts::CLI.new @stdin, @stdout
  end

  # sets expectation for stdout to receive strictly ordered sequence of exact messages
  def stdout_should_receive(*messages)
    messages.each do |message|
      @stdout.should_receive(:puts).with(message).once.ordered
    end
  end

  # sets expectation for stdout to receive message(s) containing all of the patterns (unordered)
  def stdout_should_include(*patterns)
    patterns.each do |pattern|
      re = Regexp === pattern ? pattern : Regexp.new(Regexp.escape(pattern))
      @stdout.should_receive(:puts).with(re).at_least(:once)
    end
  end

  describe 'Script Execution' do

    context 'trying to execute undefined script' do
      it 'fails' do
        cli = create_cli
        proc{cli.run( :undefined, [])}.should raise_error "Script MyScripts::Undefined not found"
      end
    end

    context 'executing pre-defined scripts' do
      MyScripts.module_eval "
      # Stub script that just puts 'OK' to stdout
      class Scriptest < Script
        def run
          puts 'OK'
          1
        end
      end"

      it 'executes pre-defined script without args' do
        cli = create_cli
        stdout_should_receive('OK')
        cli.run :scriptest, []
      end

      it 'executes pre-defined script with args' do
        cli = create_cli
        stdout_should_receive('OK')
        cli.run :scriptest, [1, 2, 3, :four, 'five']
      end

      it 'returns return value of Script#run() when running pre-defined script' do
        cli = create_cli
        cli.run( :scriptest, []).should == 1
      end
    end

    context 'executing scripts with snake_case names' do
      MyScripts.module_eval "
      # Stub script that just puts 'OK' to stdout
      class SnakeScript < Script
        def run
          puts 'OK'
        end
      end"

      it 'executes scripts with snake_case name' do
        cli = create_cli
        stdout_should_receive('OK')
        cli.run :snake_script, []
      end
    end
  end
end