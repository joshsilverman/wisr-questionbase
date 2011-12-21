# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111216170745) do

  create_table "answers", :force => true do |t|
    t.integer  "question_id"
    t.text     "answer"
    t.boolean  "correct"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "books", :force => true do |t|
    t.string   "name"
    t.string   "author"
    t.integer  "edition"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public",     :default => false
    t.integer  "user_id"
  end

  create_table "chapters", :force => true do |t|
    t.string   "name"
    t.integer  "number"
    t.integer  "book_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "questions", :force => true do |t|
    t.text     "question",          :limit => 255
    t.string   "topic"
    t.string   "correct_answer"
    t.string   "incorrect_answer1"
    t.string   "incorrect_answer2"
    t.string   "incorrect_answer3"
    t.integer  "user_id"
    t.integer  "chapter_id"
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resources", :force => true do |t|
    t.integer  "question_id"
    t.string   "url"
    t.boolean  "contains_answer"
    t.string   "type"
    t.integer  "begin"
    t.integer  "end"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
