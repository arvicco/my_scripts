module MyScripts

  # This script converts text copied from MSND function or struct description
  # into RDoc-compatible comment format. It also adds function and spec stub
  # (both are used by Win gem). This reduces dramatically amount of manual work
  # needed to convert MSDN info into RDoc
  #
  class Msdn < Script
    VERSION = '0.0.1'

    def run
      usage "[in_file] File containing MSDN text (reads from stdin if no infile)" if @argv.size > 1

      puts MsdnHelper.convert @argf.read
    end


  end
end