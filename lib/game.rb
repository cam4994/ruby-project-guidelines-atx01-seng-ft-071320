class MillionaireGame

    def self.introduction
        PROMPT.say("Welcome to Millionaire!!!", color: :red)
        first_time = PROMPT.yes?("Is this your first time playing?")
        if first_time == true 
            @@player= User.new_user
        else
            self.login
        end
    end

    def self.login
        previous_user = PROMPT.ask("Please enter your username.")
        #Check if the username has been used before
        @@player = User.find_by(username: previous_user)
        if !!@@player 
            player_password = PROMPT.mask("Please enter your password.")
            # If username was found, verify password
            if player_password == @@player.password
                self.game 
            else
                PROMPT.say("Incorrect password, please try again.", color: :red)
                self.login
            end
        else
            #username was not found
            PROMPT.say("Sorry, that's not a valid username! Please try again.", color: :red)
            self.login
        end
    end

    def self.game
    end

    def self.end_game
        puts "Play again soon!"
    end
end

