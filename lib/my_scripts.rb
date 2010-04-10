# Top level namespace
module MyScripts
  require 'pathname'

  VERSION_FILE = Pathname.new(__FILE__).dirname + '../VERSION'   # :nodoc:
  VERSION = VERSION_FILE.exist? ? VERSION_FILE.read.strip : nil

  # Require ruby source file(s). Lib should be either file name or glob
  # Accepts following options:
  # :file:: Libs are required relative to this file - defaults to __FILE__
  # :dir:: Required libs are located under this dir name - defaults to gem name
  #
  def self.require_lib( lib, opts={} )
    file = Pathname.new(opts[:file] || __FILE__)
    name = file.dirname + (opts[:dir] || file.basename('.*')) + lib.gsub(/(?<!.rb)$/, '.rb')
    Pathname.glob(name.to_s).sort.each {|rb| require rb}
  end

  # Requires ruby source file(s). Accepts either single name or Array of filenames/globs
  # Accepts following options:
  # :file:: Libs are required relative to this file - defaults to __FILE__
  # :dir:: Required libs are located under this dir name - defaults to gem name
  #
  def self.require_libs(libs, opts={})
    p opts, VERSION
    [libs].flatten.each {|lib| require_lib lib, opts }
  end

end  # module MyScripts

MyScripts.require_libs %W[script cli **/*]
