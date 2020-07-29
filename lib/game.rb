class MillionaireGame

    def self.introduction
        PROMPT.say("Welcome to Millionaire!!!", color: :red)
        menu_option = PROMPT.select("MAIN MENU", %W(Start Instructions Quit), active_color: :bright_blue)
        if menu_option == "Start"
            first_time = PROMPT.yes?("Is this your first time playing?")
            if first_time == true 
                @@player= User.new_user
                self.start_game
            else
                self.login
            end
        elsif menu_option == "Instructions"
            self.instructions 
        else
            self.end_game
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
        @@question_amounts = [100, 200, 300, 500, 1000, 2000, 4000, 8000, 16000, 32000, 64000, 125000, 2500000, 500000, 1000000]
        @prize_money = 0
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
        self.display
        question = self.next_question
        choices = [question.correct_answer, question.incorrect_answer1, question.incorrect_answer2, question.incorrect_answer3].shuffle
        #Check to see which lifelines are available
        if Lifeline.get_lifeline_fifty.available == true
            choices << "Fifty-Fifty Lifeline"
        end
        if Lifeline.get_lifeline_cut.available == true
            choices << "Cut Question Lifeline"
        end
        PROMPT.say("If you answer the next question correctly, your prize money will increase to $#{@question_amount}!!")
        answer_choice = PROMPT.select("#{question.problem}", choices, per_page: 4, active_color: :bright_blue, cycle: true)
        #See if answer was correct, incorrect or a lifeline
        if answer_choice == question.correct_answer
            PROMPT.say("Congratulations! #{answer_choice} is correct!", color: :bright_green)
            @prize_money = @question_amount
            #Check to see if that was the final question 
            if @prize_money == 1000000
                self.winner
            else 
            self.main
            end
        elsif answer_choice == "Fifty-Fifty Lifeline"
            #Activate fifty-fifty WORK ON THIS*************
        elsif answer_choice == "Cut Question Lifeline"
            #activate cut_question WORK ON THIS************
        else
            PROMPT.say("Sorry, that's incorrect. The correct answer was #{question.correct_answer}.", color: :bright_red)
            self.missed_question
        end
    end

    def self.next_question
        @question_amount = @@question_amounts.shift
        #First five questions easy, second five medium and third five hard
        if @question_amount < 2000 
            Question.get_easy_question
        elsif @question_amount >=2000 && @question_amount <64000
            Question.get_medium_question
        else
            Question.get_hard_question
        end
    end

    def self.display
        PROMPT.say("User: #{@@player.username}", color: :bright_red)
        PROMPT.say("Current prize money: $#{@prize_money}", color: :bright_green)
        lifelines = []
        if Lifeline.get_lifeline_fifty.available == true
            lifelines << Lifeline.get_lifeline_fifty.name
        end
        if Lifeline.get_lifeline_cut.available == true
            lifelines << Lifeline.get_lifeline_cut.name
        end
        lifelines = lifelines.join(" and ")
        PROMPT.say("Available Lifelines: #{lifelines}", color: :bright_blue)
    end

    def self.missed_question
        if @prize_money == 0
            PROMPT.say("You didn't win any money... at least you tried.")
        else
            PROMPT.say("That's okay #{@@player.username} you still won $#{@prize_money} of fake money! Be proud!", color: :bright_green)
        end
        answer = PROMPT.yes?("Would you like to play a new game?")
        #if player answered yes, start a new game
        if answer 
            self.start_game
        else
            self.end_game
        end
    end

    def self.instructions
    end

    def self.end_game
        puts "Play again soon!"
    end
end

