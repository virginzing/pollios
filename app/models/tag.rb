class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :polls, through: :taggings, source: :poll
end
