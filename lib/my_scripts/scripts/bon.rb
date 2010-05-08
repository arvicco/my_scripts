module MyScripts
  # This script uses Mr.Bones gem to create new project skeleton, local git repo and
  # initiate remote repo on github
  #
  class Bon < Script
    VERSION = '0.1.0'
    DEFAULT_SKELETON = 'basic'

    def run
      usage "name Summary or description goes here" if @argv.empty?

      # First Arg should be project name
      name = @argv.shift

      # All the other args lumped into summary, or default summary
      summary = @argv.empty? ? "New project #{name}" : @argv.join(' ')

      puts "Creating Bones project #{name} with summary: #{summary}"

      success = system %Q[bones create --github "#{summary}" -s #{DEFAULT_SKELETON} #{name}]

      if success
        system "cd #{name} && git grep FIXME"
      end
    end
  end
end