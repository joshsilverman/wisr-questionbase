class RemoveKeywordsFromQuestions < ActiveRecord::Migration
  def change
    remove_column :questions, :words
  end
end
