module MyScripts
  class Gitcp < Script
    def run
      usage "[bump] Commit message goes here" if @argv.empty?

      # If first Arg is a number, it indicates version bump
      bump = @argv[0].to_i > 0 ? @argv.shift.to_i : 0

      # All the other args lumped into message, or default message
      message = @argv.empty? ? 'Commit' : @argv.join(' ')
      # Timestamp added to message
      message += " #{Time.now.to_s[0..-6]}"

      puts "Committing (versionup =#{bump}) with message: #{message}"

      system %Q[git add --all]
      system %Q[git commit -a -m "#{message}" --author arvicco]
      case bump
        when 1..9
          system %Q[rake version:bump:patch]
        when 10..99
          system %Q[rake version:bump:minor]
        when 10..99
          system %Q[rake version:bump:major]
      end
      system %Q[git push]
    end
  end
end
