require 'spec_helper'

module MyScriptsTest

  describe 'Script Execution (in general)' do
    MyScripts.module_eval do
      # Stub script that outputs @argv, prompts to stdout and echoes/returns what it gets from stdin
      class Scriptest < Script  #one word for script name
        def run
          puts @argv
          puts 'Say it:'
          puts gotten = gets
          gotten
        end
      end

      # Stub script that just puts 'OK' to stdout
      class SnakeScript < Script
        def run
          puts 'OK'
        end
      end

      # Stub script that outputs usage notes
      class UsageScript < Script
        def run
          usage 'Blah'
        end
      end

      # Stub script that outputs usage notes
      class VersionedUsageScript < Script
        VERSION = '0.0.13'
        def run
          usage 'Blah'
        end
      end

      # Stub script that calls system
      class SystemScript < Script
        def run
          system 'Blah'
        end
      end
    end

    context 'trying to execute undefined script' do
      it 'fails' do
        cli = create_cli
        expect{cli.run( :undefined, [])}.to raise_error "Script MyScripts::Undefined not found"
      end
    end

    context 'scripts without arguments' do
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

    context 'printing usage' do
      context 'unversioned script' do
        it 'outputs script name, GEM version and usage note to stdout, then exits' do
          cli = create_cli
          usage_regexp = Regexp.new("Script usage_script #{MyScripts::VERSION} - Usage")
          stdout_should_receive(usage_regexp)
          stdout_should_receive(/Blah/)
          expect{cli.run :usage_script, []}.to raise_error SystemExit
        end
      end
      context 'versioned script' do
        it 'outputs script name, SCRIPT version and usage note to stdout, then exits' do
          cli = create_cli
          stdout_should_receive(/Script versioned_usage_script 0.0.13 - Usage/)
          stdout_should_receive(/Blah/)
          expect{cli.run :versioned_usage_script, []}.to raise_error SystemExit
        end
      end
    end

    context 'scripts calling system' do
      it 'calls system method on cli.kernel' do
        cli = create_cli :system => 'OK'
        system_should_receive('Blah')
        cli.run(:system_script, []).should == 'OK'
      end
    end

    context 'scripts with snake_case names' do
      it 'executes scripts with snake_case name' do
        cli = create_cli
        stdout_should_receive('OK')
        cli.run :snake_script, []
      end
    end
  end
end