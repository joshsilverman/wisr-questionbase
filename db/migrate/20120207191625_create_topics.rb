class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :topic
      t.timestamps
    end

    create_table :questions_topics, :id => false do |t|
        t.integer :question_id
        t.integer :topic_id
    end
  end
end
