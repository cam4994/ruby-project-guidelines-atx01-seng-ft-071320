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
        answer_choice = PROMPT.select("#{question.problem}", choices, per_page: 4, active_color: :bright_blue, cycle: true)
    end

    def self.activate_cut_question
    
    end
end