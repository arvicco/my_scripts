module MyScripts
  # This script wraps up all work done on project in current directory,
  # adds all new(unversioned) files to git, commits all work done so far,
  # optionally bumps project version and pushes changes to remote repo
  #
  class Gitto < Script
    def run
      usage "[0.1.2 - version, 100/10/1 - bump major/minor/patch, .patch - add patch] Commit message goes here" if @argv.empty?

      # First Arg may indicate version command if it matches pattern
      ver = @argv[0] =~ /^(\d+\.\d+\.\d+(?:\.(.*?))?|\.(.*?)|\d{1}0{0,2})$/ ? @argv[0].shift : nil

      # All the other args lumped into message, or default message
      message = @argv.empty? ?  "Commit #{Time.now.to_s[0..-6]}" : @argv.join(' ')

      puts "Committing #{ ver ? "(version = #{ver}) " : ""}with message: #{message}"

      system %Q{rake version[#{ver}]} if ver
      system %Q{git add --all}
      system %Q{git commit -a -m "#{message}" --author arvicco}
      system %Q{git push}
    end
  end
end
