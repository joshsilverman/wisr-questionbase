class Keyword < ActiveRecord::Base
    has_and_belongs_to_many :questions
end
