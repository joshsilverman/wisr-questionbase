class Chapter < ActiveRecord::Base
    belongs_to :book
    has_many :questions	
    belongs_to :feedback

    validates_presence_of :number
    def question_count
      questions.count
    end
end
