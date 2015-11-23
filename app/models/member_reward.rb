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
#  reward_id      :integer
#

class MemberReward < ActiveRecord::Base
  extend Enumerize
  acts_as_paranoid
  self.table_name = 'campaign_members'

  # TODO: GET RID OF THIS SHIT!!!!
  enumerize :reward_status, in: { waiting_announce: 0, receive: 1, not_receive: -1 }, predicates: true, scope: true

  belongs_to :campaign
  belongs_to :reward
  belongs_to :member
  belongs_to :poll
  belongs_to :poll_series
  attr_accessor :message

  validates_uniqueness_of :serial_code, allow_nil: true, allow_blank: true
  validates_uniqueness_of :ref_no, allow_nil: true, allow_blank: true

  scope :with_all_relations, -> { includes({reward: :campaign}, {campaign: :rewards}, :poll, :poll_series) }

  scope :without_deleted, -> { where(deleted_at: nil) }
  scope :for_member_id, -> (member_id) { where(member_id: member_id).order(created_at: :desc) }

  default_scope { with_deleted }
  
  after_commit :flush_cache

  self.per_page = 10

  def received?
    reward_status == 'receive'
  end

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

end
