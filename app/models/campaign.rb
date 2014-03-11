class Campaign < ActiveRecord::Base
  mount_uploader :photo_campaign, PhotoCampaignUploader
  belongs_to :member
  attr_accessor :poll_ids

  validates :name, :begin_sample, :end_sample, presence: true
  validates :limit, presence: true, numericality: { greater_than: 0 }
  
  has_many :polls
  has_many :poll_series

  has_many :campaign_guests
  has_many :guests, through: :campaign_guests, source: :guest

  has_many :campaign_members
  has_many :members, through: :campaign_members, source: :member

  after_create :set_campaign_poll
  before_update :check_campaign_poll

  def set_campaign_poll
    if self.poll_ids.present?
      poll_id = self.poll_ids
      split_poll = poll_id.split(",").collect{|id| id.to_i }
      Poll.where("id IN (?)", split_poll).each do |poll|
        poll.update(campaign_id: id)
      end
    end
  end

  def check_campaign_poll
    old_poll_ids = polls.pluck(:id)
    edit_poll_ids = poll_ids.split(",").collect{|id| id.to_i }

    old_poll_ids.each do |pid|
      Poll.find(pid).update_attributes!(campaign_id: nil) unless edit_poll_ids.include?(pid)
    end

    edit_poll_ids.each do |pid|
      Poll.find(pid).update(campaign_id: id) unless old_poll_ids.include?(pid)
    end

  end

  def prediction(member_id)
    sample = (begin_sample..end_sample).to_a.sample
    puts "your lucky : #{sample}"
    if used < limit
      if sample % end_sample == 0
        unless campaign_members.find_by_member_id(member_id)
          @campaign = campaign_members.create!(member_id: member_id, luck: true, serial_code: generate_serial_code)
          increment!(:used)
        end
      else
        unless campaign_members.find_by_member_id(member_id)
          @campaign = campaign_members.create!(member_id: member_id, luck: false)
        end
      end
    else
      puts "This campaign is limit."
    end
    @campaign
  end

  def generate_serial_code
    return "POLLIOSCODE" + id.to_s + Time.now.to_i.to_s
  end

  def as_json(options={})
    {
      id: id,
      name: name,
      expire: expire.to_i,
      photo_campaign: photo_campaign.url(:thumbnail),
      used: used,
      limit: limit,
      created_at: created_at.to_date.to_date
    }
  end
  
end
