class CampaignMember < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :member
  belongs_to :poll
  belongs_to :poll_series
  
  attr_accessor :message

  self.per_page = 10

  def self.list_reward(member_id)
    where("member_id = ? AND luck = ?", member_id, true).order('created_at desc').includes(:poll, :poll_series, {:campaign => :rewards})
  end

  def as_json(options={})
    {
      id: id,
      luck: luck,
      serial_code: serial_code,
      redeem: redeem,
      redeem_at: redeem_at.to_i.presence || "",
      ref_no: ref_no || "",
      created_at: created_at.to_i,
      title: campaign.get_reward_title,
      detail: campaign.get_reward_detail,
      expire: campaign.get_reward_expire,
      redeem_myself: campaign.redeem_myself
    }
  end
end
