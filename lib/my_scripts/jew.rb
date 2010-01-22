module MyScripts
  class Jew < Script
    def run
      usage "project_name Summary or description goes here" if @argv.empty?

      # First Arg should be project name
      project = @argv.shift

      # All the other args lumped into summary, or default summary
      summary = @argv.empty? ? "New project #{project}" : @argv.join(' ')

      puts "Creating Jeweler project #{project} with summary: #{summary}"

      system %Q["jeweler --rspec --cucumber --create-repo --summary "#{summary}" --description "#{summary}" #{project}"]
    end
  end
end