class Question < ActiveRecord::Base
  belongs_to :chapter
  belongs_to :user
  has_many :answers
  has_many :resources
end
