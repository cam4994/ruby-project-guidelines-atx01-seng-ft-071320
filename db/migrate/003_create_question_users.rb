class CreateQuestionUsers < ActiveRecord::Migration[5.2]
    def change 
        create_table :question_users do |t|
            t.integer :user_id 
            t.integer :question_id
            t.boolean :answered_correctly
        end
    end
end