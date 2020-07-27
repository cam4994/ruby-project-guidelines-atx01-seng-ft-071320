class Question < ActiveRecord::Base
    has_many :question_users
    has_many :users, through: :question_users

    def self.store_questions
        url = "https://opentdb.com/api.php?amount=50&type=multiple"
        uri = URI.parse(url)
        response = Net::HTTP.get_response(uri)
        response.body
        api_questions = JSON.parse(response.body)["results"]
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
end