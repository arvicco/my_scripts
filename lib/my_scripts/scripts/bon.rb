module MyScripts
  # This script uses Mr.Bones gem to create new project skeleton, local git repo and
  # initiate remote repo on github
  #
  class Bon < Script
    DEFAULT_SKELETON = 'basic'
    def run
      usage "name Summary or description goes here" if @argv.empty?

      # First Arg should be project name
      name = @argv.shift

      # All the other args lumped into summary, or default summary
      summary = @argv.empty? ? "New project #{project}" : @argv.join(' ')

      puts "Creating Bones project #{name} with summary: #{summary}"

      system %Q[bones create --github "#{summary}" -s #{DEFAULT_SKELETON} #{name}]
    end
  end
end