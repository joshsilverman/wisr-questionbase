class AddMetadataToQuestionsAndAnswers < ActiveRecord::Migration
  def change
    add_column :questions, :rationale, :text
    add_column :questions, :difficulty, :string
    add_column :questions, :reference, :string
    add_column :questions, :keywords, :string
    add_column :questions, :objective, :text
    add_column :questions, :state_objective, :string
    add_column :questions, :state, :string
    add_column :questions, :question_type, :string
    # remove_column :questions, :correct_answer
    # remove_column :questions, :incorrect_answer1
    # remove_column :questions, :incorrect_answer2
    # remove_column :questions, :incorrect_answer3

    add_column :answers, :feedback, :text 
    
    add_column :resources, :table, :text
    add_column :resources, :required, :boolean
  end
end
