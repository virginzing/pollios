class Comment < ActiveRecord::Base
  belongs_to :poll
  belongs_to :member

  self.per_page = 10
  
end
