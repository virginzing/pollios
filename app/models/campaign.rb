class Campaign < ActiveRecord::Base
  include CampaignsHelper
  # has_paper_trail
  mount_uploader :photo_campaign, PhotoCampaignUploader

  attr_accessor :poll_ids, :poll_id

  store_accessor :reward_info

  # validates :name, :begin_sample, :end_sample, presence: true
  # validates :limit, presence: true, numericality: { greater_than: 0 }
  validates :name, :limit, presence: true

  validates_uniqueness_of :name, :on => :create, scoped: :company_id

  # has_one :poll
  # has_one :poll_series

  has_many :polls
  has_many :poll_series

  has_many :campaign_guests, dependent: :destroy
  has_many :guests, through: :campaign_guests, source: :guest

  has_many :campaign_members, dependent: :destroy
  has_many :members, through: :campaign_members, source: :member

  belongs_to :member

  has_many :rewards, dependent: :destroy

  # after_create :set_campaign_poll
  # before_update :check_campaign_poll

  accepts_nested_attributes_for :polls

  accepts_nested_attributes_for :rewards, :reject_if => lambda { |a| a[:title].blank? }, :allow_destroy => true

  self.per_page = 10
  
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
    CampaignMember.transaction do 
      sample = (begin_sample..end_sample).to_a.sample
      puts "your lucky : #{sample}"
      if expire < Time.now
        puts "Campaign was expired"
        message = "Expired"
      elsif used >= limit
        puts "This campaign is limit."
        message = "Limited"
      elsif campaign_members.find_by(member_id: member_id, poll_id: poll_id).present?
        puts "used to redeem."
        message = "Used"
      else
        if sample % end_sample == 0
          @campaign = campaign_members.create!(member_id: member_id, luck: true, serial_code: generate_serial_code, poll_id: poll_id, ref_no: generate_ref_no)
          increment!(:used)
          Rails.cache.delete([member_id, 'reward'])
          message = "Lucky"
          ApnRewardWorker.perform_in(10.seconds, @campaign.id) unless Rails.env.test?
        else
          @campaign = campaign_members.create!(member_id: member_id, luck: false, poll_id: poll_id, ref_no: generate_ref_no)
          message = "Fail"
        end
      end
      [@campaign, message]
    end
  end

  def free_reward(member_id)
    @campaign = campaign_members.create!(member_id: member_id, luck: true, serial_code: generate_serial_code, ref_no: generate_ref_no)
    increment!(:used)
    Rails.cache.delete([member_id, 'reward'])
  end

  def prediction_questionnaire(member_id, poll_series_id)
    CampaignMember.transaction do 
      sample = (begin_sample..end_sample).to_a.sample
      puts "your lucky : #{sample}"
      if expire < Time.now
        puts "Campaign was expired"
        message = "Expired"
      elsif used >= limit
        puts "This campaign is limit."
        message = "Limited"
      elsif campaign_members.find_by(member_id: member_id, poll_series_id: poll_series_id).present?
        puts "used to redeem."
        message = "Used"
      else
        if sample % end_sample == 0
          @campaign = campaign_members.create!(member_id: member_id, luck: true, serial_code: generate_serial_code, poll_series_id: poll_series_id, ref_no: generate_ref_no)
          increment!(:used)
          Rails.cache.delete([member_id, 'reward'])
          message = "Lucky"
          ApnRewardWorker.perform_in(10.seconds, @campaign.id) unless Rails.env.test?
        else
          @campaign = campaign_members.create!(member_id: member_id, luck: false, poll_series_id: poll_series_id, ref_no: generate_ref_no)
          message = "Fail"
        end
      end
      [@campaign, message]
    end
  end

  def generate_serial_code
    return id.to_s + Time.zone.now.to_i.to_s
  end

  def generate_ref_no
    return "P" + Time.zone.now.to_i.to_s
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
    reward_expire.present? ? reward_expire.to_i : ""
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
      redeem_myself: redeem_myself,
      reward_expire: get_reward_expire
    }
  end
  
end
