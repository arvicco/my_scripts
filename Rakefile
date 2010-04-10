
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

task :default => 'test:run'
task 'gem:release' => 'test:run'

Bones {
  name 'my_scripts'
  authors 'arvicco'
  email 'arvitallian@gmail.com'
  url 'http://github.com/arvicco/my_scipts'
  ignore_file '.gitignore'
  test_files [ "spec/**.rb" ]
}

