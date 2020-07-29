class Question < ActiveRecord::Base
    has_many :question_users
    has_many :users, through: :question_users

    def self.store_questions
        @@questions = []
        url = "https://opentdb.com/api.php?amount=50&type=multiple"
        uri = URI.parse(url)
        response = Net::HTTP.get_response(uri)
        response.body
        api_questions = JSON.parse(response.body)["results"]
        #Take API results and get rid of errors with ' and "
        api_questions = self.fix_api_questions(api_questions)
        api_questions.each do |api_question|
            Question.find_or_create_by(problem: api_question["question"]) do |question|
                question.category = api_question["category"]
                question.difficulty = api_question["difficulty"]
                question.problem = api_question["question"]
                question.correct_answer = api_question["correct_answer"]
                question.incorrect_answer1 = api_question["incorrect_answers"][0]
                question.incorrect_answer2 = api_question["incorrect_answers"][1]
                question.incorrect_answer3 = api_question["incorrect_answers"][2]
            end
        end
    end

    def self.fix_api_questions(questions)
        questions.each do |question|
            question["question"].gsub!("&#039;", "'")
            question["question"].gsub!('&quot;', '"')
            question["correct_answer"].gsub!("&#039;", "'")
            question["correct_answer"].gsub!('&quot;', '"')
            question["incorrect_answers"][0].gsub!("&#039;", "'")
            question["incorrect_answers"][0].gsub!('&quot;', '"')
            question["incorrect_answers"][1].gsub!("&#039;", "'")
            question["incorrect_answers"][1].gsub!('&quot;', '"')
            question["incorrect_answers"][2].gsub!("&#039;", "'")
            question["incorrect_answers"][2].gsub!('&quot;', '"')
        end
        questions
    end

    def self.get_easy_question
        question = Question.where("difficulty = ?", "easy").sample(1)[0]
        #make sure questions can't be repeated
        if @@questions.include?(question)
            self.get_easy_question
        else
            @@questions << question
        end 
        question
    end

    def self.get_medium_question
        question = Question.where("difficulty = ?", "medium").sample(1)[0]
        #make sure questions can't be repeated
        if @@questions.include?(question)
            self.get_medium_question
        else
            @@questions << question
        end 
        question
    end
    
    def self.get_hard_question
        question = Question.where("difficulty = ?", "hard").sample(1)[0]
        #make sure questions can't be repeated
        if @@questions.include?(question)
            self.get_hard_question
        else
            @@questions << question
        end 
        question
    end

end