class CreateQuestions < ActiveRecord::Migration[5.2]
    def change 
        create_table :questions do |t|
            t.string :category
            t.string :difficulty
            t.string :problem
            t.string :correct_answer
            t.string :incorrect_answer1
            t.string :incorrect_answer2
            t.string :incorrect_answer3 
        end
    end
end