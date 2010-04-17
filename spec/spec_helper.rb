require 'my_scripts'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
end

module MyScriptsTest

  def create_cli(opts={})
    @stdout = opts[:stdout] || mock('stdout').as_null_object
    @stdin = opts[:stdin] || mock('stdin')
    if opts[:input]
      @stdin.stub(:gets).and_return(*opts[:input])
    else
      @stdin.stub(:gets).and_return('')
    end
    @kernel = Kernel
    if opts[:system]
      @kernel = mock('Kernel')
      @kernel.stub(:system).and_return(*opts[:system])
    end
    @cli = MyScripts::CLI.new(@stdin, @stdout, @kernel)
  end

  def cli(command_line, argf=ARGF)
    raise "Command line should be non-empty String" unless command_line.respond_to?(:split) && command_line != ''
    argv = command_line.split(' ')
    @cli.run argv.shift.to_sym, argv, argf
  end

  # Sets expectation for Kernel to receive system call with specific messages/patterns
  def system_should_receive(*messages)
    entity_should_receive(@kernel, :system, *messages)
  end

  # Sets expectation for stdout to receive puts with specific messages/patterns
  def stdout_should_receive(*messages)
    entity_should_receive(@stdout, :puts, *messages)
  end

  # Sets expectation for entity to receive either:
  # :message(s) - strictly ordered sequence of exact messages
  # :pattern(s) - specific patterns (unordered)
  #
  def entity_should_receive(entity, method, *messages)
    # If symbol is coming after method, it must be message type
    type = messages.first.is_a?(Symbol) ? messages.shift : :message
    messages.each do |message|
      if type.to_s =~ /message/
        entity.should_receive(method).with(message).once.ordered
      elsif type.to_s =~ /(pattern|regex)/
        re = Regexp === message ? message : Regexp.new(Regexp.escape(message))
        entity.should_receive(method).with(re).at_least(:once)
      end
    end
  end

  # Lists files of specific type
  def test_files(dir)

    files_dir = Pathname(__FILE__).dirname + 'files' + dir
    infiles_glob = (files_dir + '*_in.txt').to_s
    outfiles_glob = (files_dir + '*_out.txt').to_s
    infiles = Pathname.glob(infiles_glob)
    outfiles = Pathname.glob(outfiles_glob)

    if infiles.size == outfiles.size
      infiles.zip(outfiles)
    else
      nil
    end
  end

end