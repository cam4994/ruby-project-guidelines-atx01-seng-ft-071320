class MillionaireGame

    def self.introduction
        puts "".light_cyan.bold.blink
        menu_option = PROMPT.select("MAIN MENU", %W(Start High_Scores Instructions Quit), active_color: :bright_blue)
        if menu_option == "Start"
            first_time = PROMPT.yes?("Is this your first time playing?")
            if first_time == true 
                @@player= User.new_user
                self.start_game
            else
                self.login
            end
        elsif menu_option == "High_Scores"
            User.high_scores
            self.introduction
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
        #Reset lifelines
        Lifeline.get_lifeline_fifty.update(available: true)
        Lifeline.get_lifeline_cut.update(available: true)
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
        @questionuser = QuestionUser.create(user: @@player, question: question)
        choices = [question.correct_answer, question.incorrect_answer1, question.incorrect_answer2, question.incorrect_answer3].shuffle
        #Check to see which lifelines are available
        if Lifeline.get_lifeline_fifty.available == true
            choices << "Fifty-Fifty Lifeline"
        end
        if Lifeline.get_lifeline_cut.available == true
            choices << "Cut Question Lifeline"
        end
        PROMPT.say("If you answer the next question correctly, your prize money will increase to $#{@question_amount}!!")
        puts ""
        sleep(1)
        answer_choice = PROMPT.select("#{question.problem}", choices, per_page: 4, active_color: :bright_blue, cycle: true)
        if answer_choice == "Fifty-Fifty Lifeline"
            answer_choice = Lifeline.activate_fifty_fifty(question)
        elsif answer_choice == "Cut Question Lifeline"
            question = Lifeline.activate_cut_question(@question_amount)
            @questionuser = QuestionUser.create(user: @@player, question: question)
            choices = [question.correct_answer, question.incorrect_answer1, question.incorrect_answer2, question.incorrect_answer3].shuffle
            answer_choice = PROMPT.select("#{question.problem}", choices, per_page: 4, active_color: :bright_blue, cycle: true)
        end
        self.check_if_correct(answer_choice, question)
    end

    def self.check_if_correct(answer_choice, question)
        #See if answer was correct, incorrect or a lifeline
        if answer_choice == question.correct_answer
            @questionuser.answered_correctly = true
            @questionuser.save
            PROMPT.say("Congratulations! #{answer_choice} is correct!", color: :bright_green)
            2.times do 
                puts ""
            end
            @prize_money = @question_amount
            #Check to see if that was the final question 
            if @prize_money == 1000000
                self.winner
            else 
            self.main
            end
        else
            @questionuser.answered_correctly = false
            @questionuser.save
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
        if lifelines == ""
            PROMPT.say("No Lifelines Available", color: :bright_blue)
        else
            PROMPT.say("Available Lifelines: #{lifelines}", color: :bright_blue)
        end
        puts ""
        sleep(1)
    end
    def self.missed_question
        if @prize_money == 0
            PROMPT.say("You didn't win any money... at least you tried.")
        else
            PROMPT.say("That's okay #{@@player.username} you still won $#{@prize_money} of fake money! Be proud!", color: :bright_green)
        end
        self.high_score?
        answer = PROMPT.yes?("Would you like to play a new game?")
        #if player answered yes, start a new game
        if answer 
            self.start_game
        else
            self.end_game
        end
    end

    def self.high_score?
        #See if high score was passed, if so, update high score 
        if @@player.high_score == nil
            @@player.update(high_score: @prize_money)
        elsif @@player.high_score < @prize_money
            @@player.update(high_score: @prize_money)
            PROMPT.say("Congrats, this is the furthest you've ever reached! Keep going for the million!", color: :bright_green)
            sleep(0.5)
        end
    end

    def self.instructions
        #Only one lifeline may be used per question
        puts ""
        puts "Millionaire is a quiz competition in which the goal is to correctly answer a series of 15 consecutive multiple-choice questions.".light_blue
        sleep(1.5)
        puts "You must create a username or login if you are a previous player. Your high score will be recorded.".light_blue
        sleep(1.5)
        puts "Each question will have 4 answer choices, with only 1 correct answer.".light_blue
        sleep(1.5)
        puts "The question difficulty will increase every 5 questions.".light_blue
        sleep(1.5)
        puts 'Each question is worth a specified amount of "Prize Money" and is not cumulative.'.light_blue
        sleep(1.5)
        puts "If at any time the contestant gives a wrong answer, the game is over.".light_blue
        puts ""
        sleep(2)
        puts "You will have access to 2 different Lifelines.".light_green
        sleep(1.5)
        print "However, you will only be able to use ".light_green
        print "1 Lifeline per question".light_red.bold.underline
        puts " and each Lifeline can only be used once."
        sleep(1.5)
        puts "Once a question appears with the 4 answer choices, you can access the Lifelines by either scrolling down or hitting the right arrow key.".light_green
        puts ""
        sleep(1.5)
        print "The ".light_green
        print "Fifty-Fifty Lifeline".light_red
        puts " can be used to get rid of two incorrect answer choices.".light_green
        sleep(1.5)
        puts ""
        print "The ".light_green
        print "Cut Question Lifeline".light_red
        puts " can be used to swap questions and get a new one.".light_green
        puts ""
        sleep(1.5)
        puts ""
        puts ""
        option = PROMPT.select("OPTIONS", %W(Menu Quit), active_color: :bright_blue)
        if option == "Quit"
            self.end_game
        else
            self.introduction
        end
    end

    def self.end_game
        puts "Play again soon!"
    end
end

