module MyScripts
  # Starts and controls rabbitmq server
  class Rabbit < Script
    VERSION = '0.1.0'

    def run
      if RUBY_PLATFORM =~ /windows|mingw32/

        error 'ERLANG_HOME not set' unless ENV['ERLANG_HOME']
        rabbit_hole = ENV['ERLANG_HOME'] + '/lib/rabbitmq_server-1.7.0/sbin'
        case @argv.shift
          when /start/
            system "#{rabbit_hole}/rabbitmq-server.bat #{@argv.join(' ')}"
          when /stop/
            system "#{rabbit_hole}/rabbitmqctl.bat stop #{@argv.join(' ')}"
          when /ctl/
            system "#{rabbit_hole}/rabbitmqctl.bat #{@argv.join(' ')}"
          else
            usage ["start [args] - starts rabbitmq node", "stop [args] - stops running rabbitmq node",
                                                            "ctl [args] - controls rabbitmq node"]
        end
      else

        rabbit_hole = `which rabbitmqctl`.strip.split('/')[0..-2].join('/')
        case @argv.shift
          when /start/
            system "sudo #{rabbit_hole}/rabbitmq-server #{@argv.join(' ')}"
          when /stop/
            system "sudo #{rabbit_hole}/rabbitmqctl stop #{@argv.join(' ')}"
          when /ctl/
            system "sudo #{rabbit_hole}/rabbitmqctl #{@argv.join(' ')}"
          else
            usage ["start [args] - starts rabbitmq node", "stop [args] - stops running rabbitmq node",
                                                            "ctl [args] - controls rabbitmq node"]
        end
      end
    end
  end
end
