# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 4) do

  create_table "lifelines", force: :cascade do |t|
    t.string "name"
    t.boolean "available"
  end

  create_table "question_users", force: :cascade do |t|
    t.integer "user_id"
    t.integer "question_id"
    t.boolean "answered_correctly"
  end

  create_table "questions", force: :cascade do |t|
    t.string "category"
    t.string "difficulty"
    t.string "problem"
    t.string "correct_answer"
    t.string "incorrect_answer1"
    t.string "incorrect_answer2"
    t.string "incorrect_answer3"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "password"
    t.integer "high_score"
  end

end
