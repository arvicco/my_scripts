require 'spec_helper'
require 'my_scripts/scripts/shared'

module MyScriptsTest

  describe MyScripts::Msdn do
    before(:each) do
      create_cli
      @name  = 'msdn'
    end

#    it_should_behave_like "script with args"

    context 'With explicit in and out files' do

      it 'reads from infile, writes to outfile' do
        test_files(@name).each do |infile, outfile|
          stdout_should_receive [outfile.readlines.map(&:chomp).join("\n")   ]
          cli "#{@name} #{infile}", infile
        end
      end
    end
  end
end
