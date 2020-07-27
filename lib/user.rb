class User < ActiveRecord::Base
    has_many :question_users
    has_many :questions, through: :question_users

    def self.new_username
        new_username = prompt.ask("Please select a new username.")
        confirm_username = prompt.yes?("You selected #{new_username}. Are you sure?")
        if confirm_username == false 
            self.new_username 
        else
            if User.find_by(username: new_username)
                puts "#{new_username} is already taken. "
                self.new_username
            else
                User.create(username: new_username)
            end
        end

        

    end
end