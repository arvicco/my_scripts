#task :default => 'test:run'
#task 'gem:release' => 'test:run'

#desc 'Bundle dependencies'
#task :bundle do
#  output = `bundle check 2>&1`
#
#  unless $?.to_i == 0
#    puts output
#    system "bundle install"
#    puts
#  end
#end