module MyScripts
  # Starts and controls rabbitmq server
  class Rabbit < Script
    def run
      case @argv.shift 
        when /start/
          system "%ERLANG_HOME%/lib/rabbitmq_server-1.7.0/sbin/rabbitmq-server.bat #{ARGV.join(' ')}"
        when /stop/
          system "%ERLANG_HOME%/lib/rabbitmq_server-1.7.0/sbin/rabbitmqctl.bat stop #{ARGV.join(' ')}"
        when /ctl/
          system "%ERLANG_HOME%/lib/rabbitmq_server-1.7.0/sbin/rabbitmqctl.bat #{ARGV.join(' ')}"
        else
          usage ["start [args] - starts rabbitmq node", "mqctl [args] - controls rabbitmq node"]
      end
    end
  end
end
