class Lifeline < ActiveRecord::Base
    belongs_to :user

    def self.get_lifeline_fifty
        self.find_by(name: "Fifty-Fifty")
    end

    def self.get_lifeline_cut
        self.find_by(name: "Cut Question")
    end

    def self.activate_fifty_fifty(question)
        #Change fifty_fifty lifeline avaiability to false 
        self.get_lifeline_fifty.update(available: false)
        #Get rid of two incorrect answers
        choices = [question.incorrect_answer1, question.incorrect_answer2, question.incorrect_answer3].shuffle
        2.times do 
            choices.pop
        end
        #Add correct answer to choices array and then shuffle
        choices << question.correct_answer
        choices.shuffle
        PROMPT.say("Two incorrect answers have been removed.", color: :bright_green)
        sleep(1)
        puts ""
        answer_choice = PROMPT.select("#{question.problem}", choices, per_page: 4, active_color: :bright_blue, cycle: true)
    end

    def self.activate_cut_question(question_amount)
        #Change Cut Question lifeline availability to false
        PROMPT.say("Thanks to your Cut Question Lifeline, here is your new question!", color: :bright_green)
        sleep(1)
        puts ""
        self.get_lifeline_cut.update(available: false)
        #Get new question
        if question_amount < 2000 
            Question.get_easy_question
        elsif question_amount >=2000 && question_amount <64000
            Question.get_medium_question
        else
            Question.get_hard_question
        end
    end
end