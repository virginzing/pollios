class CampaignMember < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :member
  belongs_to :poll
  belongs_to :poll_series
  
  self.per_page = 10

  def self.list_reward(member_id)
    where("member_id = ? AND luck = ?", member_id, true).order('created_at desc').includes(:member, :campaign)
  end
end
