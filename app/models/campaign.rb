# == Schema Information
#
# Table name: campaigns
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  photo_campaign  :string(255)
#  used            :integer          default(0)
#  limit           :integer          default(0)
#  member_id       :integer
#  created_at      :datetime
#  updated_at      :datetime
#  begin_sample    :integer          default(1)
#  end_sample      :integer
#  expire          :datetime
#  description     :text
#  how_to_redeem   :text
#  company_id      :integer
#  type_campaign   :integer
#  redeem_myself   :boolean          default(FALSE)
#  reward_info     :hstore
#  reward_expire   :datetime
#  system_campaign :boolean          default(FALSE)
#  announce_on     :datetime
#

class Campaign < ActiveRecord::Base
  include CampaignsHelper
  # has_paper_trail
  mount_uploader :photo_campaign, PhotoCampaignUploader

  attr_accessor :poll_ids, :poll_id, :unexpire

  store_accessor :reward_info

  # validates :name, :begin_sample, :end_sample, presence: true
  # validates :limit, presence: true, numericality: { greater_than: 0 }
  validates :name, :limit, presence: true

  validates_uniqueness_of :name, :on => :create, scope: :company_id

  # has_one :poll
  # has_one :poll_series

  has_many :polls
  has_many :poll_series

  has_many :campaign_members, dependent: :destroy
  has_many :members, through: :campaign_members, source: :member

  has_many :gift_logs, dependent: :destroy
  
  belongs_to :member
  belongs_to :company

  has_many :rewards, dependent: :destroy

  scope :without_system, -> { where(system_campaign: false) }

  after_commit :flush_cache

  # after_create :set_campaign_poll
  # before_update :check_campaign_poll

  accepts_nested_attributes_for :polls

  accepts_nested_attributes_for :rewards, :reject_if => lambda { |a| a[:title].blank? }, :allow_destroy => true

  self.per_page = 10

  def self.cached_find(id)
    Rails.cache.fetch([name, id]) do
      @campaign = Campaign.find_by(id: id)
      raise ExceptionHandler::NotFound, ExceptionHandler::Message::Campaign::NOT_FOUND unless @campaign.present?
      @campaign
    end
  end

  def flush_cache
    Rails.cache.delete([self.class.name, id])
  end

  
  def set_campaign_poll
    if self.poll_ids.present?
      poll_id = self.poll_ids.class == Array ? self.poll_ids.delete_if{|e| e == "" } : self.poll_ids.split(",").collect{|id| id.to_i }.delete_if {|e| e == "" }
      Poll.where("id IN (?)", poll_id).each do |poll|
        poll.update(campaign_id: id)
      end
    end
    # if self.poll_id.present?
    #   Poll.find(self.poll_id).update_attributes!(campaign_id: id)
    # end
  end

  def update_reward_random_of_poll(poll, list_member)
    list_reward_with_member_ids = campaign_members.where(poll: poll).pluck(:member_id)
    members_receive_reward = list_member
    members_not_receive_reward = list_reward_with_member_ids - members_receive_reward

    #receive
    campaign_members.with_reward_status(:waiting_announce).where(poll: poll, member_id: members_receive_reward).find_each do |reward|
      reward.update!(serial_code: generate_serial_code, reward_status: :receive)
    end

    #not receive
    campaign_members.with_reward_status(:waiting_announce).where(poll: poll, member_id: members_not_receive_reward).find_each do |reward|
      reward.update!(reward_status: :not_receive)
    end

    update!(used: used + members_receive_reward.size)
    
    unless Rails.env.test?
      ReceiveRandomRewardPollWorker.perform_in(5.second, poll.member_id, poll.id, members_receive_reward)
      NotReceiveRandomRewardPollWorker.perform_in(5.second, poll.member_id, poll.id, members_not_receive_reward)
    end

    true
  end

  def check_campaign_poll
    old_poll_ids = polls.pluck(:id)
    edit_poll_ids = poll_ids.class == Array ? poll_ids.delete_if {|e| e == "" } : poll_ids.split(",").collect{|id| id.to_i }.delete_if {|e| e == "" }

    old_poll_ids.each do |pid|
      Poll.find(pid).update_attributes!(campaign_id: nil) unless edit_poll_ids.include?(pid)
    end

    edit_poll_ids.each do |pid|
      Poll.find(pid).update(campaign_id: id) unless old_poll_ids.include?(pid)
    end
  end

  def prediction(member_id, poll_id)
    raise ExceptionHandler::UnprocessableEntity, "This campaign was expired." if expire < Time.now
    raise ExceptionHandler::UnprocessableEntity, "This campaign was limit." if used >= limit
    raise ExceptionHandler::UnprocessableEntity, "You used to get this reward of poll." if campaign_members.find_by(member_id: member_id, poll_id: poll_id).present?
    
    if random_later?
      @reward = campaign_members.create!(member_id: member_id, reward_status: :waiting_announce, poll_id: poll_id, ref_no: generate_ref_no)
    else
      sample = (begin_sample..end_sample).to_a.sample

      if sample % end_sample == 0
        @reward = campaign_members.create!(member_id: member_id, reward_status: :receive, serial_code: generate_serial_code, poll_id: poll_id, ref_no: generate_ref_no)

        self.with_lock do
          self.used += 1
          self.save!
        end

        Rails.cache.delete([member_id, 'reward'])
        if @reward
          RewardWorker.perform_async(@reward.id) unless Rails.env.test?
        end
      else
        @reward = campaign_members.create!(member_id: member_id, reward_status: :not_receive, poll_id: poll_id, ref_no: generate_ref_no)
        poll = Poll.cached_find(poll_id)
        NotReceiveRandomRewardPollWorker.perform_async(member.id, poll_id, [member_id], "Sorry! You don't get reward from poll: #{poll.title}") if @reward
      end
    end
    @reward
  end

  def free_reward(member_id, gift_log = nil)
    if gift_log.nil?
      @reward = campaign_members.create!(member_id: member_id, reward_status: :receive, serial_code: generate_serial_code, ref_no: generate_ref_no, gift: true)
    else
      @reward = campaign_members.create!(member_id: member_id, reward_status: :receive, serial_code: generate_serial_code, ref_no: generate_ref_no, gift: true, gift_log_id: gift_log.id)
    end
    
    self.with_lock do
      self.used += 1
      self.save!
    end
    
    Rails.cache.delete([member_id, 'reward'])
    @reward
  end

  def prediction_questionnaire(member_id, poll_series_id)

    raise ExceptionHandler::UnprocessableEntity, "This campaign was expired." if expire < Time.now
    raise ExceptionHandler::UnprocessableEntity, "This campaign was limit." if used >= limit
    raise ExceptionHandler::UnprocessableEntity, "You used to get this reward of feedback." if campaign_members.find_by(member_id: member_id, poll_series_id: poll_series_id).present?

    if random_later?
      @reward = campaign_members.create!(member_id: member_id, reward_status: :waiting_announce, poll_series_id: poll_series_id, ref_no: generate_ref_no)
    else
      sample = (begin_sample..end_sample).to_a.sample

      if sample % end_sample == 0
        @reward = campaign_members.create!(member_id: member_id, reward_status: :receive, serial_code: generate_serial_code, poll_series_id: poll_series_id, ref_no: generate_ref_no)
        
        self.with_lock do
          self.used += 1
          self.save!
        end
        
        Rails.cache.delete([member_id, 'reward'])
        if @reward
          RewardWorker.perform_async(@reward.id) unless Rails.env.test?
        end
      else
        @reward = campaign_members.create!(member_id: member_id, reward_status: :not_receive, poll_series_id: poll_series_id, ref_no: generate_ref_no)
      end
    end
    @reward
  end

  def generate_serial_code
    begin
      serial_code = ('S' + SecureRandom.hex(6)).upcase
    end while CampaignMember.exists?(serial_code: serial_code)
    serial_code
  end

  def generate_ref_no
    begin
      ref_no = ('R' + SecureRandom.hex(6)).upcase
    end while CampaignMember.exists?(ref_no: ref_no)
    ref_no
  end

  def get_photo_campaign
    photo_campaign.url(:thumbnail).presence || ""
  end

  def get_original_photo_campaign
    photo_campaign.present? ? photo_campaign.url : ""
  end

  def get_reward_title
    rewards.present? ? rewards.first.title : ""
  end

  def get_reward_detail
    rewards.present? ? rewards.first.detail : ""
  end

  def get_reward_expire
    rewards.present? ? rewards.first.reward_expire.to_i : ""
  end

  def unexpired?
    ((expire - created_at) / 1.year) > 80 ? true : false
  end

  def as_json(options={})
    {
      id: id,
      name: name.presence || "",
      description: description.presence || "",
      how_to_redeem: how_to_redeem.presence || "",
      expire: expire.to_i,
      photo_campaign: get_photo_campaign,
      original_photo_campaign: get_original_photo_campaign,
      used: used,
      limit: limit,
      owner_info: member.present? ? MemberInfoFeedSerializer.new(member).as_json() : System::DefaultMember.new.to_json,
      created_at: created_at.to_i,
      type_campaign: type_campaign,
      announce_on: announce_on.to_i,
      random_reward: begin_sample == end_sample ? false : true
    }
  end
  
end
