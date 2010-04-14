module MyScripts
  # This script uses Jeweler to create new project skeleton, local git repo and
  # initiate remote repo on github
  #
  class Jew < Script
    def run
      usage "project_name Summary or description goes here" if @argv.empty?

      # First Arg should be project name
      name = @argv.shift

      # All the other args lumped into summary, or default summary
      summary = @argv.empty? ? "New project #{name}" : @argv.join(' ')

      puts "Creating Jeweler project #{name} with summary/description: #{summary}"

      success = system \
      %Q[jeweler --rspec --cucumber --create-repo --summary "#{summary}" --description "#{summary}" #{name}]
      if success
        puts "Now you need to fix these files:"
        system "cd #{name} && git grep FIXME"
      end
    end
  end
end