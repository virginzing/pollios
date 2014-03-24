class CampaignMember < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :member

  self.per_page = 10
end
