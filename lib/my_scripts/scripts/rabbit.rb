module MyScripts
  # Starts and controls rabbitmq server
  class Rabbit < Script
    VERSION = '0.1.1'
    USAGE = ["start [args] - starts rabbitmq node",
             "stop [args] - stops running rabbitmq node",
             "reset - resets rabbit hard, killing all data",
             "ctl [args] - controls rabbitmq node"]

    def run
      if RUBY_PLATFORM =~ /windows|mingw32/

        error 'ERLANG_HOME not set' unless ENV['ERLANG_HOME']
        rabbit_hole = ENV['ERLANG_HOME'] + '/lib/rabbitmq_server-1.7.0/sbin'
        case @argv.shift
          when /start/
            system "#{rabbit_hole}/rabbitmq-server.bat #{@argv.join(' ')}"
          when /stop/
            system "#{rabbit_hole}/rabbitmqctl.bat stop_app"
            system "#{rabbit_hole}/rabbitmqctl.bat force_reset"
            system "#{rabbit_hole}/rabbitmqctl.bat start_app"
          when /ctl/
            system "#{rabbit_hole}/rabbitmqctl.bat #{@argv.join(' ')}"
          else
            usage USAGE
        end
      else

        rabbit_hole = `which rabbitmqctl`.strip.split('/')[0..-2].join('/')
        case @argv.shift
          when /start/
            system "sudo #{rabbit_hole}/rabbitmq-server #{@argv.join(' ')}"
          when /stop/
            system "sudo #{rabbit_hole}/rabbitmqctl stop #{@argv.join(' ')}"
          when /reset/
            system "sudo #{rabbit_hole}/rabbitmqctl stop_app"
            system "sudo #{rabbit_hole}/rabbitmqctl force_reset"
            system "sudo #{rabbit_hole}/rabbitmqctl start_app"
          when /ctl/
            system "sudo #{rabbit_hole}/rabbitmqctl #{@argv.join(' ')}"
          else
            usage USAGE
        end
      end
    end
  end
end
