module MyScripts
  # This script wraps up all work done on project in current directory,
  # adds all new(unversioned) files to git, commits all work done so far,
  # optionally bumps project version and pushes changes to remote repo
  #
  class Gitto < Script
    def run
      usage "[bump: 1 - patch, 10 - minor, 100 - major] Commit message goes here" if @argv.empty?

      # If first Arg is a number, it indicates version bump
      bump = @argv[0].to_i > 0 ? @argv.shift.to_i : 0

      # All the other args lumped into message, or default message
      message = @argv.empty? ? 'Commit' : @argv.join(' ')
      # Timestamp added to message
      message += " #{Time.now.to_s[0..-6]}"

      puts "Committing (versionup =#{bump}) with message: #{message}"

      case bump
        when 1..9
          system %Q[rake version:bump:patch]
        when 10..99
          system %Q[rake version:bump:minor]
        when 10..99
          system %Q[rake version:bump:major]
      end
      system %Q[git add --all]
      system %Q[git commit -a -m "#{message}" --author arvicco]
      system %Q[git push]
    end
  end
end
