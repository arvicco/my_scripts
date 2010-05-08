require 'spec_helper'
require 'my_scripts/scripts/shared'

module MyScriptsTest
  VERSION_COMMANDS = %W[1 10 100 1.2.3 1.2.3.beta2 0.0.1.patch .patch .b2a]

  describe MyScripts::Gitto do
    before(:each) do
      create_cli(:system=> 'ok')
      @name  = 'gitto'
    end

    it_should_behave_like "script with args"

    context 'No version command' do
      it 'Commits with message, pushes to remote' do
        message = 'This is bomb!'
        stdout_should_receive "Adding all the changes",
                              "Committing everything with message: #{message}",
                              "Pushing to (default) remote for branch: * master"
        system_should_receive "git add --all",
                              %Q{git commit -a -m "#{message}" --author arvicco},
                              "git push"
        cli "#{@name} #{message}"
      end

      context 'With version command' do
        it 'Commits with message if message given, pushes to remote' do
          VERSION_COMMANDS.each do |command|
            message = 'This is bomb!'

            stdout_should_receive "Adding all the changes",
                                  "Committing everything with message: #{message}",
                                  "Pushing to (default) remote for branch: * master"
            system_should_receive %Q{rake "version[#{command},#{message}]"},
                                  "git add --all",
                                  %Q{git commit -a -m "#{message}" --author arvicco},
                                  "git push"
            cli "#{@name} #{command} #{message}"
          end
        end

        it 'Commits and pushes with default timestamped message if no message' do
          VERSION_COMMANDS.each do |command|
            stdout_should_receive "Adding all the changes",
                                  "Committing everything with message: Commit #{Time.now.to_s[0..-6]}",
                                  "Pushing to (default) remote for branch: * master"
            system_should_receive "rake version[#{command}]",
                                  "git add --all",
                                  %Q{git commit -a -m "Commit #{Time.now.to_s[0..-6]}" --author arvicco},
                                  "git push"
            cli "#{@name} #{command}"
          end
        end
      end
    end
  end
end
