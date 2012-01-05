class Question < ActiveRecord::Base
  belongs_to :chapter
  belongs_to :user
  has_many :answers, :dependent => :destroy
  has_many :resources, :dependent => :destroy
end
