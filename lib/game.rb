class MillionaireGame

    def self.introduction
        puts "".light_cyan.bold.blink                                                          
        menu_option = PROMPT.select("MAIN MENU", %W(Start High_Scores Instructions Quit), active_color: :bright_blue)
        if menu_option == "Start"
            CLI::UI::StdoutRouter.enable
            first_time=CLI::UI.ask("Is this your first time playing?", options: %w(Yes No))
            case first_time
            when "Yes"
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
        CLI::UI::StdoutRouter.enable
        CLI::UI::Frame.open('Log in') do
            previous_user = CLI::UI.ask("Please enter your username.")
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
    end

    def self.start_game
        Question.store_questions
        #Reset lifelines
        Lifeline.get_lifeline_fifty.update(available: true)
        Lifeline.get_lifeline_cut.update(available: true)
        @@question_amounts = [100, 200, 300, 500, 1000, 2000, 4000, 8000, 16000, 32000, 64000, 125000, 2500000, 500000, 1000000]
        @prize_money = 0
        puts "You will start with a question worth $100. As you answer questions correctly, the value of the questions will increase, but so will the difficulty!"
            start = PROMPT.select("Are you ready?", %w(Begin Edit_Info Quit ), active_color: :bright_blue)
        case start
        when "Quit"
            self.end_game
        when "Edit_Info"
            self.edit_info
        else
            self.main
        end 
    end

    def self.main
        self.millionaire_banner
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
        PROMPT.say("If you answer the next question correctly, you'll win' $#{@question_amount}!!")
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
        CLI::UI::StdoutRouter.enable
        CLI::UI::Frame.open("Player Info") do
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
    end

    def self.missed_question
        if @prize_money == 0
            PROMPT.say("You didn't win any money... at least you tried.")
        else
            PROMPT.say("That's okay #{@@player.username} you still won $#{@prize_money} of fake money! Be proud!", color: :bright_green)
        end
        self.high_score?
        CLI::UI::StdoutRouter.enable
        answer = CLI::UI.ask("Would you like to play again?", options: %w(Yes No))
        case answer
        when "Yes"
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
        CLI::UI::StdoutRouter.enable
            CLI::UI::Frame.open('How to play') do
                puts ""
                puts "Millionaire is a quiz competition in which the goal is to correctly answer a series of 15 consecutive multiple-choice questions.".light_blue
                puts "You must create a username or login if you are a previous player. Your high score will be recorded.".light_blue
                puts "Each question will have 4 answer choices, with only 1 correct answer.".light_blue
                puts "The question difficulty will increase every 5 questions.".light_blue
                puts 'Each question is worth a specified amount of "Prize Money" and is not cumulative.'.light_blue
                puts "If at any time the contestant gives a wrong answer, the game is over.".light_blue
                puts ""
            end
            CLI::UI::StdoutRouter.enable
            CLI::UI::Frame.open('Lifelines') do
                puts "You will have access to two different Lifelines.".light_green
                print "However, you will only be able to use ".light_green
                puts "1 Lifeline per question".light_red.bold.underline
                puts "Once a question appears with the 4 answer choices, you can access the Lifelines by either scrolling down or hitting the right arrow key.".light_green
                puts ""
                print "The ".light_green
                print "Fifty-Fifty Lifeline".light_red
                puts " can be used to get rid of two incorrect answer choices.".light_green
                puts ""
                print "The ".light_green
                print "Cut Question Lifeline".light_red
                puts " can be used to swap questions and get a new one.".light_green
                puts ""
            end
        option = PROMPT.select("OPTIONS", %W(Menu Quit), active_color: :bright_blue)
        if option == "Quit"
            self.end_game
        else
            self.introduction
        end
    end

    def self.edit_info
        pick_an_edit = PROMPT.select("Change Username or Password?", %w(Username Password Back))
        case pick_an_edit
           when "Username"
                self.change_username
                MillionaireGame.main
           when "Password"
                self.change_password
                puts "Your password was successfully changed"
                MillionaireGame.main 
           else "Back"
            MillionaireGame.main             
        end
    end

    def self.change_password
        old_password = PROMPT.mask("Please enter your old password", required: true)
        if old_password == @@player.password
            new_password = PROMPT.mask("Please enter your new password", required: true) do |q|
            q.validate(/^(?=.*[a-zA-Z])(?=.*[0-9]).{6,}$/)
            q.messages[:valid?] = 'Your passowrd must be at least 6 characters and include one number and one letter'
          end
            confirm_password = PROMPT.mask("Please confirm your new password", required: true)
            if new_password == confirm_password
                @@player.password = nil
                @@player.password = new_password
                @@player.save
                self.start_game
            else
                puts "Those didn't match. Please try again!"
                self.change_password
            end
        else
            puts "That was not right."
            puts "Please try again"
            self.change_password
        end
    end

    def self.change_username
        CLI::UI::StdoutRouter.enable
        new_username=CLI::UI.ask("Please enter your username.")
        confirm_new_username=CLI::UI.ask("Is #{new_username}, what you'd like to be known as?", options: %w(Yes No))
        case confirm_new_username
        when "Yes"
            if User.find_by(username: new_username) == nil
                @@player.username=new_username
                @@player.save
                self.start_game
        else
            puts "#{new_username}, is already taken. Please enter a different name."
            self.change_username
        end
        else
            self.edit_info
        end
    end

    def self.end_game
        puts "Play again soon!"
    end

    def self.millionaire_banner
        puts "
        /$$      /$$ /$$ /$$ /$$ /$$                               /$$                     /$$ /$$ /$$
       | $$$    /$$$|__/| $$| $$|__/                              |__/                    | $$| $$| $$
       | $$$$  /$$$$ /$$| $$| $$ /$$  /$$$$$$  /$$$$$$$   /$$$$$$  /$$  /$$$$$$   /$$$$$$ | $$| $$| $$
       | $$ $$/$$ $$| $$| $$| $$| $$ /$$__  $$| $$__  $$ |____  $$| $$ /$$__  $$ /$$__  $$| $$| $$| $$
       | $$  $$$| $$| $$| $$| $$| $$| $$  \  $$| $$  \  $$  /$$$$$$$| $$| $$  \ __/| $$$$$$$$|__/|__/|__/
       | $$\   $ | $$| $$| $$| $$| $$| $$  | $$| $$  | $$ /$$__  $$| $$| $$      | $$_____/            
       | $$ \ /  | $$| $$| $$| $$| $$|  $$$$$$/| $$  | $$|  $$$$$$$| $$| $$      |  $$$$$$$ /$$ /$$ /$$
       |__/     |__/|__/|__/|__/|__/ \ ______/ |__/  |__/ \ _______/|__/|__/       \ _______/|__/|__/|__/".yellow
    end
end

