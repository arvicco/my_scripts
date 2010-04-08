require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

module MyScriptsTest

  # creates new CLI object with mock stdin and stdout,
  # stdin optionally preloaded with fake user input
  def create_cli( opts={} )
    @stdout = opts[:stdout] || mock('stdout').as_null_object
    @stdin = opts[:stdin] || mock('stdin')
    if opts[:input]
      @stdin.stub(:gets).and_return(*opts[:input])
    else
      @stdin.stub(:gets).and_return('')
    end
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

    context 'scripts without arguments' do
      MyScripts.module_eval do
        # Stub script that prompts to stdout and echoes/returns what it gets from stdin
        class Scriptest < Script
          def run
            puts 'Say it:'
            puts gotten = gets
            gotten
          end
        end
      end

      it 'cli.run executes pre-defined script' do
        cli = create_cli
        expect{cli.run :scriptest, []}.to_not raise_error
      end

      it 'script outputs to given stdout' do
        cli = create_cli
        stdout_should_receive('Say it:')
        cli.run :scriptest, []
      end

      it 'script gets value from given stdin' do
        cli = create_cli :input => 'yes'
        stdout_should_receive('yes')
        cli.run( :scriptest, [])
      end

      it 'script returns last value of run() method' do
        cli = create_cli :input => 'yes'
        cli.run( :scriptest, []).should == 'yes'
      end
    end

    context 'scripts with arguments' do
      before(:each) {@given_args = [1, 2, 3, :four, 'five']}
      MyScripts.module_eval do
        # Stub script that prompts to stdout and echoes/returns what it gets from stdin
        class Scriptest < Script
          def run
            puts @argv
            puts 'Say it:'
            puts gotten = gets
            gotten
          end
        end
      end

      it 'cli.run executes pre-defined script' do
        cli = create_cli
        expect{cli.run :scriptest, @given_args}.to_not raise_error
      end

      it 'script outputs to given stdout' do
        cli = create_cli
        stdout_should_receive('Say it:')
        cli.run :scriptest, @given_args
      end

      it 'script receives given arguments in @argv' do
        cli = create_cli
        stdout_should_receive(@given_args)
        cli.run :scriptest, @given_args
      end

      it 'script gets value from given stdin' do
        cli = create_cli :input => 'yes'
        stdout_should_receive('yes')
        cli.run( :scriptest, @given_args)
      end

      it 'script returns last value of run() method' do
        cli = create_cli :input => 'yes'
        cli.run( :scriptest, @given_args).should == 'yes'
      end
    end

    context 'scripts with snake_case names' do
      MyScripts.module_eval do
        # Stub script that just puts 'OK' to stdout
        class SnakeScript < Script
          def run
            puts 'OK'
          end
        end
      end

      it 'executes scripts with snake_case name' do
        cli = create_cli
        stdout_should_receive('OK')
        cli.run :snake_script, []
      end
    end
  end
end