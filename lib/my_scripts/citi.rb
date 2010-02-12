module MyScripts
  # This script converts given QIF file (with downloaded citibank statement)
  # into Quicken 2008 compatible format, and outputs it into new file for
  # import into Quicken
  #
  class Citi < Script
    INFILE_ENCODING = 'CP1251:UTF-8'  # Encoding pair of input file ('File external:Ruby internal')
    OUTFILE_ENCODING = 'CP1252:UTF-8' # Encoding pair of output file ('File external:Ruby internal')

    REPLACES = {
            /Pokupka Masterkard .*(Detskiy Mir).*/ => "Detski Mir\nLChildcare",
            /Pokupka Masterkard .*(Medicina).*/ => "AO Medicina\nLMedical:Medicine",
            /Pokupka Masterkard .*(Pharmacy).*/ => "\\1\nLMedical:Medicine",
            /Pokupka Masterkard .*(Alye Parusa).*/ => "\\1\nLGroceries",
            /Pokupka Masterkard .*(Perekrestok).*/ => "\\1\nLGroceries",
            /Pokupka Masterkard .*(Ile De Beaute).*/ => "\\1\nLPersonal Care",
            /Pokupka Masterkard .*(Beeline).*/ => "\\1\nLCommunications:Telephone",
            /Pokupka Masterkard (.+) (Moscow Ru.+|Moskva Ru.+)/ => "\\1\nM\\2\nLHousehold",
            /Vkhodyashchij Platezh(.+Bank Moskvy)/ => "Incoming transfer\nM\\1\nL[BM New Prestige]",
            /Oplata Dolg Kr Karta(.+)/ => "Transfer to Credit card\nM\\1\nL[Citi MC]",
            /Snyatie Nalichnykh(.+)/ => "Cash withdrawal\nM\\1\nL[Cash RUB]",
            /Vznos Nalichnykh(.+)/ => "Cash deposit\nM\\1\nL[Cash RUB]",
            /Kom Za Obsluzhivanie/ => "Citibank\nMService fee\nLFinance:Bank Charge",
            'Universam '=> '',
            'Supermarket '=> ''
    }

    def run
      usage "in_file.qif [out_file.qif]" if @argv.empty?

      in_file = @argv.first

      # If 2nd Arg is given, it is out_file name, otherwise derive from in_file name
      out_file = @argv[1] ? @argv[1] : in_file.sub(/\.qif|$/, '_out.qif')

      # All the other args lumped into message, or default message
      message = @argv.empty? ? 'Commit' : @argv.join(' ')
      # Timestamp added to message
      message += " #{Time.now.to_s[0..-6]}"

      puts "Committing (versionup =#{bump}) with message: #{message}"

      system %Q[git add --all]
      case bump
        when 1..9
          system %Q[rake version:bump:patch]
        when 10..99
          system %Q[rake version:bump:minor]
        when 10..99
          system %Q[rake version:bump:major]
      end
      system %Q[git commit -a -m "#{message}" --author arvicco]
      system %Q[git push]
    end
  end
end
