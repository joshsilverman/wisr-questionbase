class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.integer :question_id
      t.string :url
      t.boolean :contains_answer
      t.string :type
      t.integer :begin
      t.integer :end

      t.timestamps
    end
  end
end
