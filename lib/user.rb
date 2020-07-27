class User < ActiveRecord::Base
    has_many :question_users
    has_many :questions, through: :question_users
end