class Question < ActiveRecord::Base
    has_many :question_users
    has_many :users, through: :question_users
end