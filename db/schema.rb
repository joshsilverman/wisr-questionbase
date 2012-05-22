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

ActiveRecord::Schema.define(:version => 20120521182527) do

  create_table "active_admin_comments", :force => true do |t|
    t.string    "resource_id",   :null => false
    t.string    "resource_type", :null => false
    t.integer   "author_id"
    t.string    "author_type"
    t.text      "body"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
    t.string    "email",                                 :default => "", :null => false
    t.string    "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string    "reset_password_token"
    t.timestamp "reset_password_sent_at"
    t.timestamp "remember_created_at"
    t.integer   "sign_in_count",                         :default => 0
    t.timestamp "current_sign_in_at"
    t.timestamp "last_sign_in_at"
    t.string    "current_sign_in_ip"
    t.string    "last_sign_in_ip"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "answers", :force => true do |t|
    t.integer   "question_id"
    t.text      "answer"
    t.boolean   "correct"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.text      "feedback"
  end

  create_table "authorships", :force => true do |t|
    t.integer   "user_id"
    t.integer   "book_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "books", :force => true do |t|
    t.string    "name"
    t.string    "author"
    t.integer   "edition"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.boolean   "public",     :default => false
    t.integer   "user_id"
  end

  create_table "chapters", :force => true do |t|
    t.string    "name"
    t.integer   "number"
    t.integer   "book_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "status",     :default => 0
    t.text      "media_url"
    t.integer   "author_id"
  end

  create_table "feedbacks", :force => true do |t|
    t.boolean  "long",              :default => false
    t.boolean  "hard",              :default => false
    t.boolean  "easy",              :default => false
    t.boolean  "correct",           :default => false
    t.boolean  "media_timing",      :default => false
    t.boolean  "media_relevant",    :default => false
    t.boolean  "topic_missing",     :default => false
    t.boolean  "topic_appropriate", :default => false
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoices", :force => true do |t|
    t.integer  "user_id"
    t.float    "hours"
    t.text     "task"
    t.boolean  "paid",       :default => false
    t.float    "cost"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "keywords", :force => true do |t|
    t.string    "keyword"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "keywords_questions", :id => false, :force => true do |t|
    t.integer "keyword_id"
    t.integer "question_id"
  end

  create_table "questions", :force => true do |t|
    t.text     "question"
    t.string   "topic"
    t.integer  "user_id"
    t.integer  "chapter_id"
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "rationale"
    t.string   "difficulty"
    t.string   "reference"
    t.text     "objective"
    t.string   "state_objective"
    t.string   "state"
    t.string   "question_type"
    t.integer  "feedback_id"
  end

  create_table "resources", :force => true do |t|
    t.text      "url"
    t.string    "media_type"
    t.boolean   "contains_answer"
    t.integer   "begin"
    t.integer   "end"
    t.integer   "question_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.text      "article_text"
    t.text      "table"
    t.boolean   "required"
  end

  create_table "users", :force => true do |t|
    t.string    "email",                                 :default => "", :null => false
    t.string    "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string    "reset_password_token"
    t.timestamp "reset_password_sent_at"
    t.timestamp "remember_created_at"
    t.integer   "sign_in_count",                         :default => 0
    t.timestamp "current_sign_in_at"
    t.timestamp "last_sign_in_at"
    t.string    "current_sign_in_ip"
    t.string    "last_sign_in_ip"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "first_name"
    t.string    "last_name"
    t.string    "school"
    t.string    "user_type"
    t.string    "user_token"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
