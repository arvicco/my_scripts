module MyScripts
  # This script converts given QIF file (with downloaded citibank statement)
  # into Quicken 2008 compatible format, and outputs it into new file for
  # import into Quicken
  #
  class Citi < Script
    INFILE_ENCODING = 'CP1251:UTF-8'  # Encoding pair of input file ('File external:Ruby internal')
    OUTFILE_ENCODING = 'CP1252:UTF-8' # Encoding pair of output file ('File external:Ruby internal')
#    STDOUT_ENCODING = 'CP866:UTF-8'   # Encoding pair of stdout ('Stdout external:Ruby internal')

    REPLACE = {
            'Universam '=> '',
            'Supermarket '=> '',
            'Pokupka Masterkard ' => '',
            /.*(Detskiy Mir).*/ => "Detski Mir\nLChildcare",
            /.*(Legioner).*/ => "Legioner\nLBooks & Media:DVDs",
            /.*(Gudman).*/ => "Goodman\nLDining",
            /.*(Sushi Vesla).*/ => "\\1\nLDining",
            /.*(Starbucks).*/ => "\\1\nLDining",
            /.*(Medicina).*/ => "AO Medicina\nLMedical:Medicine",
            /.*(Pharmacy).*/ => "\\1\nLMedical:Medicine",
            /.*(Alye Parusa).*/ => "\\1\nLGroceries",
            /.*(Perekrestok).*/ => "\\1\nLGroceries",
            /.*(Ile De Beaute).*/ => "\\1\nLPersonal Care",
            /.*(Beeline).*/ => "\\1\nLCommunications:Telephone",
            /(.+) (Moscow Ru.*|Moskva Ru.*)/ => "\\1\nM\\2\nLHousehold",
            /Vkhodyashchij Platezh(.+Bank Moskvy)/ => "Incoming transfer\nM\\1\nL[BM 2yr Prestige]",
            /Platezh Cherez Citibank Online/ => "Incoming transfer\nL[Citi RUB]",
            /Oplata Dolg Kr Karta(.+)/ => "Transfer to Credit card\nM\\1\nL[Citi MC]",
            /Snyatie Nalichnykh(.+)/ => "Cash withdrawal\nM\\1\nL[Cash RUB]",
            /Vznos Nalichnykh(.+)/ => "Cash deposit\nM\\1\nL[Cash RUB]",
            /Kom Za Obsluzhivanie/ => "Citibank\nMService fee\nLFinance:Bank Charge",
            /Komissiya Za Snyatie Nalichnykh/ => "Citibank\nMCash withdrawal fee\nLFinance:Bank Charge"
    }

    def run
      usage "in_file.qif [out_file.qif]" if @argv.empty?

      in_file = @argv.first

      # If 2nd Arg is given, it is out_file name, otherwise derive from in_file name
      out_file = @argv[1] ? @argv[1] : in_file.sub(/\.qif|$/i, '_out.qif')

#      $stdout.set_encoding(STDOUT_ENCODING, :undef=>:replace)
      File.open(out_file, 'w:'+ OUTFILE_ENCODING, :undef => :replace) do |outfile|
        File.open(in_file, 'r:'+ INFILE_ENCODING, :undef => :replace).each_line do |line|
          type = line[0]
          text = line[1..-1]
          case type # Indicates type of field
            when 'D' # Date field - convert to MM/DD/YYYY format expected by Quicken
              text.gsub! /(\d+)\/(\d+)\/(\d+)/, '\2/\1/\3'
            when 'P' # Payee field
              # Convert payee from Cyrillic to Latin translit
              text.translit!
              # Capitalize each word and remove extra whitespaces (leaves first char intact)
              text = text.scan(/[\w&]+/).map{|word| word.capitalize}.join(' ')
              # Preprocess Payee field making pre-defined replacements
              REPLACE.each {|key, value| text.gsub!(key, value)}
            when 'M' # Memo field - drop if empty
              if text.rstrip.empty?
                text.clear
                type.clear
              end
          end
          line = type+text
          outfile.puts line unless line.empty?
        end
      end
    end
  end
end