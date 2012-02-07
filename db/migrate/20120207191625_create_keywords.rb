class CreateKeywords < ActiveRecord::Migration
  def change
    create_table :keywords do |t|
      t.string :keyword
      t.timestamps
    end

    create_table :keywords_questions, :id => false do |t|
        t.integer :keyword_id
        t.integer :question_id
    end
  end
end