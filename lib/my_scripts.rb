module MyScripts
  def self.require_libs( filename, filemask )
    file = ::File.expand_path(::File.join(::File.dirname(filename), filemask.gsub(/(?<!.rb)$/,'.rb')))
    require file if File.exist?(file) && !File.directory?(file)
    Dir.glob(file).sort.each {|rb| require rb}
  end
end  # module MyScripts

%W[my_scripts/script my_scripts/cli **/*].each {|rb| MyScripts.require_libs(__FILE__, rb)}
