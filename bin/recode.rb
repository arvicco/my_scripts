# encoding: UTF-8
INFILE_NAME = 'ACCT_101.QIF'
OUTFILE_NAME = 'TEST.QIF'
INFILE_ENCODING = 'CP1251:UTF-8'  # Encoding pair of log file ('File external:Ruby internal')
OUTFILE_ENCODING = 'CP1252:UTF-8' # Encoding pair of log file ('File external:Ruby internal')
#STDOUT_ENCODING = 'CP866:UTF-8'   # Encoding pair of stdout ('Stdout external:Ruby internal')
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

class String
  TRANSLIT_RUSSIAN = 'АБВГДЕЁЗИЙКЛМНОПРСТУФЪЫЬЭабвгдеёзийклмнопрстуфъыьэ'
  TRANSLIT_LATIN = "ABVGDEEZIJKLMNOPRSTUF\"Y'Eabvgdeezijklmnoprstuf\"y'e"
  TRANSLIT_DOUBLES = {'Ж'=>'ZH', 'Х'=>'KH', 'Ц'=>'TS', 'Ч'=>'CH', 'Ш'=>'SH', 'Щ'=>'SHCH', 'Ю'=>'YU', 'Я'=>'YA',
                      'ж'=>'zh', 'х'=>'kh', 'ц'=>'ts', 'ч'=>'ch', 'ш'=>'sh', 'щ'=>'shch', 'ю'=>'yu', 'я'=>'ya'}

  def translit!
    TRANSLIT_DOUBLES.each {|key, value| self.gsub!(key, value)}
    self.tr!(TRANSLIT_RUSSIAN, TRANSLIT_LATIN)
    self
  end
end

#$stdout.set_encoding(STDOUT_ENCODING, :undef=>:replace)
File.open(OUTFILE_NAME, 'w:'+ (OUTFILE_ENCODING), :undef => :replace) do |outfile|
  File.open(INFILE_NAME, 'r:'+ (INFILE_ENCODING), :undef => :replace).each_line do |line|
    puts line, '-----------'
    case line.chars.first
      when 'D' # Date field - convert to MM/DD/YYYY format expected by Quicken
        line.gsub! /(\d+)\/(\d+)\/(\d+)/, '\2/\1/\3'
      when 'P' # Payee field
        # Convert payee from Russian to translit
        line.translit!
        # Capitalize each word and remove extra whitespaces (leaves first char intact)
        line[1..-1] = line[1..-1].scan(/\w+/).map{|word| word.capitalize}.join(' ')
        # Preprocess Payee field making pre-defined replacements
        REPLACES.each {|key, value| line.gsub!(key, value)}
      when 'M' # Memo field - drop if empty
        line.clear if line.rstrip == 'M'
    end

    outfile.puts line unless line.empty?
    puts line, '-----------'
  end
end
