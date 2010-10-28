require 'pathname'
NAME = 'my_scripts'
BASE_PATH = Pathname.new(__FILE__).dirname
LIB_PATH =  BASE_PATH + 'lib'
PKG_PATH =  BASE_PATH + 'pkg'
DOC_PATH =  BASE_PATH + 'rdoc'

$LOAD_PATH.unshift LIB_PATH.to_s
require NAME

CLASS_NAME = MyScripts
VERSION = CLASS_NAME::VERSION

gem 'rake', '~> 0.8.7'
require 'rake'

# Load rakefile tasks
Dir['tasks/*.rake'].sort.each { |file| load file }

