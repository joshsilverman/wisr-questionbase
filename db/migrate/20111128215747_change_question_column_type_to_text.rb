class ChangeQuestionColumnTypeToText < ActiveRecord::Migration
  def up
    change_column(:questions, :question, :text)
  end

  def down
    change_column(:questions, :question, :string)
  end
end
