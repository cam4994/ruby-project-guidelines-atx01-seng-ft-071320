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

    def self.set_password 
        new_password = prompt.mask("Please select a password.") do |p|
            p.validate(/\A(?=.{5,})(?=.*[A-Z])/x)
        end
        confirm_password = prompt.mask("Please re-enter password.")
        if new_password == confirm_password
            new_password
        else
            puts "The passwords did not match." 
            self.set_password
        end
    end

    def self.new_user 
        new_user = self.new_username 
        new_user.password = self.set_password 
        new_user.save 
    end

end