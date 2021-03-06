class User < ActiveRecord::Base
    has_many :question_users
    has_many :lifelines
    has_many :questions, through: :question_users

    def self.new_username
        new_username = PROMPT.ask("Please select a new username.")
        confirm_username = PROMPT.yes?("You selected #{new_username}. Are you sure?")
        if confirm_username == false 
            self.new_username 
        else
            if User.find_by(username: new_username)
                PROMPT.say("#{new_username} is already taken.", color: :red)
                self.new_username
            else
                User.create(username: new_username)
            end
        end
    end

    def self.set_password 
        new_password = PROMPT.mask("Please select a password.") do |q|
            q.validate(/^(?=.*[a-zA-Z])(?=.*[0-9]).{6,}$/)
            q.messages[:valid?] = 'Your password must be at least 6 characters and include one number and one letter'
        end
        confirm_password = PROMPT.mask("Please re-enter password.")
        if new_password == confirm_password
            new_password
        else
            PROMPT.say("The passwords did not match. Please try again.", color: :red)
            puts "\n" * 2 
            self.set_password
        end
    end

    def self.new_user 
        new_user = self.new_username 
        puts "\n" * 50
        new_user.password = self.set_password 
        puts "\n" * 50
        new_user.save 
        new_user
    end

    def self.high_scores 
        puts "\n" * 50
        PROMPT.say("          HIGH SCORES", color: :bright_green)
        puts ""
        users = self.where("high_score > 0").order("high_score DESC").limit(10)
        users.each do |user|
            print "User: ".light_red
            print "#{user.username}".light_blue.bold 
            print " ----- ".bold 
            print "High Score: ".light_red
            puts "$#{user.high_score}".yellow.bold
            sleep(1)
        end
        puts "\n" * 3
        sleep(1)
    end

    def correct_questions
        self.questions.where("answered_correctly = true")
    end

    def missed_questions
        self.questions.where("answered_correctly = false")
    end
end