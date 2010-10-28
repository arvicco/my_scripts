require 'spec_helper'

describe MyScripts::Msdn do
  before(:each) do
    @name  = 'msdn'
  end

  context 'With explicit infile, no outfile' do

    it 'reads from infile, writes to stdout' do
      test_files(@name).each do |infile, outfile|
        create_cli
        stdout_should_receive outfile.readlines.map(&:chomp).join("\n") + "\n"
        cli "#{@name} #{infile}", infile
      end
    end
  end

  it 'reads from temp file' do
    text = test_files(@name)[1].first.read
    temp_file = File.expand_path('/tmp/msdn_temp_file')
    File.open(temp_file, 'w') do |f|
      f.write(text)
    end

    lambda { @changed_text = `msdn /tmp/msdn_temp_file` }.should_not raise_error
    # puts "\n\nResult: #{@changed_text}"
  end

end
