module MyScripts
  # This script uses Mr.Bones gem to create new project skeleton, local git repo and
  # initiate remote repo on github
  #
  class Mybones < Script
    def run
      usage "project_name Summary or description goes here" if @argv.empty?

      # First Arg should be project name
      project = @argv.shift

      # All the other args lumped into summary, or default summary
      summary = @argv.empty? ? "New project #{project}" : @argv.join(' ')

      puts "Creating Bones project #{project} with summary: #{summary}"

      system %Q[bones create --github "#{summary}" -s basic #{project}]
    end
  end
end