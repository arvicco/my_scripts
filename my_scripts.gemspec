# Gemspecs should not be generated, but edited directly.
# Refer to: http://yehudakatz.com/2010/04/02/using-gemspecs-as-intended/

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'my_scripts'

Gem::Specification.new do |gem|
  gem.name        = "my_scripts"
  gem.version     = MyScripts::VERSION
  gem.summary     = %q{Describe package my_scripts}
  gem.description = %q{Describe package my_scripts}
  gem.authors     = ["arvicco"]
  gem.email       = "arvitallian@gmail.com"
  gem.homepage    = %q{http://github.com/arvicco/my_scripts}
  gem.platform    = Gem::Platform::RUBY
  gem.date        = Date.today.to_s

  # Files setup
  versioned         = `git ls-files -z`.split("\0")
  gem.files         = Dir['{bin,lib,man,spec,features,tasks}/**/*', 'Rakefile', 'README*', 'LICENSE*',
                      'VERSION*', 'CHANGELOG*', 'HISTORY*', 'ROADMAP*', '.gitignore'] & versioned
  gem.executables   = (Dir['bin/**/*'] & versioned).map{|file|File.basename(file)}
  gem.test_files    = Dir['spec/**/*'] & versioned
  gem.require_paths = ["lib"]

  # RDoc setup
  gem.has_rdoc = true
  gem.rdoc_options.concat %W{--charset=UTF-8 --main README.rdoc -S -N --title Example}
  gem.extra_rdoc_files = ["LICENSE", "HISTORY", "README.rdoc"]
    
  # Dependencies
  gem.add_development_dependency(%q{rspec}, [">= 1.2.9"])
  gem.add_development_dependency(%q{cucumber}, [">= 0"])
  #gem.add_dependency(%q{other}, [">= 1.2.9"])

  gem.rubyforge_project = ""
  gem.rubygems_version  = `gem -v`
  #gem.required_rubygems_version = ">= 1.3.6"
end

