class MillionaireGame
    @@question_amounts = [100, 200, 300, 500, 1000, 2000, 4000, 8000, 16000, 32000, 64000, 125000, 2500000, 500000, 1000000]

    def self.introduction
        PROMPT.say("Welcome to Millionaire!!!", color: :red)
        first_time = PROMPT.yes?("Is this your first time playing?")
        if first_time == true 
            @@player= User.new_user
            self.start_game
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
                self.start_game 
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

    def self.start_game
        Question.store_questions
        puts "Welcome #{@@player.username}! You will start with a question worth $100."
        puts "As you answer questions correctly, the value of the questions will increase, but so will the difficulty!"
        start = PROMPT.select("Are you ready?", %w(Begin Quit), active_color: :bright_blue)
        if start == "Quit"
            self.end_game
        else
            puts "Who wants to be a millionaire in cool ascii"
            self.main 
        end
    end

    def self.main
        question = Question.get_easy_question
    end

    def self.display

    end

    def self.end_game
        puts "Play again soon!"
    end
end

