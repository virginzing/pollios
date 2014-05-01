class CampaignGuest < ActiveRecord::Base
  belongs_to :guest
  belongs_to :campaign
  belongs_to :poll
end
