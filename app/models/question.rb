class Question < ActiveRecord::Base
  has_and_belongs_to_many :topics
  belongs_to :chapter
  belongs_to :user
  has_many :answers, :dependent => :destroy
  has_many :resources, :dependent => :destroy
end
