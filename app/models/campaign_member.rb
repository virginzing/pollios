# == Schema Information
#
# Table name: campaign_members
#
#  id             :integer          not null, primary key
#  campaign_id    :integer
#  member_id      :integer
#  serial_code    :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  redeem         :boolean          default(FALSE)
#  redeem_at      :datetime
#  poll_id        :integer
#  poll_series_id :integer
#  redeemer_id    :integer
#  ref_no         :string(255)
#  gift           :boolean          default(FALSE)
#  reward_status  :integer
#  deleted_at     :datetime
#  gift_log_id    :integer
#

class CampaignMember < ActiveRecord::Base
  acts_as_paranoid
  include CampaignMembersHelper

  belongs_to :campaign
  belongs_to :member
  belongs_to :poll
  belongs_to :poll_series

  validates_uniqueness_of :serial_code, allow_nil: true, allow_blank: true
  validates_uniqueness_of :ref_no, allow_nil: true, allow_blank: true

  scope :without_deleted, -> { where(deleted_at: nil) }

  default_scope { with_deleted }
  
  after_commit :flush_cache

  attr_accessor :message

  self.per_page = 10

  def flush_cache
    Rails.cache.delete([self.class.name, id])
  end

  def self.cached_find(id)
    Rails.cache.fetch([name, id]) do
      @reward = find_by(id: id)
      raise ExceptionHandler::NotFound, ExceptionHandler::Message::Reward::NOT_FOUND unless @reward.present?
      raise ExceptionHandler::Deleted, ExceptionHandler::Message::Reward::DELETED unless @reward.deleted_at.nil?
      @reward
    end
  end

  def self.list_reward(member_id)
    where("member_id = ?", member_id).order('created_at desc').includes(:poll, :poll_series, {:campaign => :rewards})
  end

  def as_json(options={})
    {
      id: id,
      reward_status: reward_status,
      serial_code: serial_code || "",
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
