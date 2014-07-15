class Comment < ActiveRecord::Base
  belongs_to :poll
  belongs_to :member

  WillPaginate.per_page = 10
  
end
