class PollGroup < ActiveRecord::Base

  belongs_to :poll
  belongs_to :group
  belongs_to :member
  
end
