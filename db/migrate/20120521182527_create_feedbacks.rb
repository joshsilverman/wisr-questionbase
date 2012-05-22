class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.boolean :long, :default => false
      t.boolean :hard, :default => false
      t.boolean :easy, :default => false
      t.boolean :correct, :default => false
      t.boolean :media_timing, :default => false
      t.boolean :media_relevant, :default => false
      t.boolean :topic_missing, :default => false
      t.boolean :topic_appropriate, :default => false
      t.text :comment
      t.timestamps
    end
    add_column :questions, :feedback_id, :integer
  end
end
