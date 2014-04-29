class CampaignMember < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :member
  belongs_to :poll
  
  self.per_page = 10

  def self.list_reward(member_id)
    where("member_id = ? AND luck = ? AND redeem = ?", member_id, true, false).order('created_at desc').includes(:poll, :member, :campaign)
  end
end
