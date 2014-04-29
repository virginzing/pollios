class CampaignMember < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :member
  belongs_to :poll
  
  self.per_page = 10
end
