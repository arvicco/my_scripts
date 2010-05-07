module MyScripts
  # This script wraps up all work done on project in current directory,
  # adds all new(unversioned) files to git, commits all work done so far,
  # optionally bumps project version and pushes changes to remote repo
  #
  class Gitto < Script
    VERSION_PATTERN = /^(\d+\.\d+\.\d+    # either explicit version (1.2.3)
                        (?:\.(.*?))?      # possibly followed by .build
                        |\.(.*?)          # or, just .build
                        |\d{1}0{0,2})$/x  # or, one digit followed by 0-2 zeroes (100/10/1 - bump major/minor/patch)

    def run
      usage "[0.1.2 - version, 100/10/1 - bump major/minor/patch, .build - add build] Commit message goes here" if @argv.empty?

      # First Arg may indicate version command if it matches pattern
      version_command = @argv[0] =~ VERSION_PATTERN ? @argv.shift : nil

      # All the other args lumped into message, or default message
      if @argv.empty?
        commit_message = "Commit #{Time.now.to_s[0..-6]}"
        history_message = nil
      else
        commit_message = history_message = @argv.join(' ')
      end

      # Updating version if version command set
      if version_command
        puts "Updating version with #{version_command}"
        if history_message
          system %Q{rake "version[#{version_command},#{history_message}]"}
        else
          system %Q{rake version[#{version_command}]}
        end
      end

      puts "Committing everything with message: #{commit_message}"
      system %Q{git add --all}
      system %Q{git commit -a -m "#{commit_message}" --author arvicco}

      puts "Pushing to remote(s)"
      system %Q{git push}
    end
  end
end
