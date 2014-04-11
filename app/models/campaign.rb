class Campaign < ActiveRecord::Base
  # has_paper_trail
  mount_uploader :photo_campaign, PhotoCampaignUploader

  attr_accessor :poll_ids, :poll_id

  validates :name, :begin_sample, :end_sample, presence: true
  validates :limit, presence: true, numericality: { greater_than: 0 }


  has_one :poll
  has_one :poll_series

  # has_one :poll
  # has_one :poll_series

  has_many :campaign_guests, dependent: :destroy
  has_many :guests, through: :campaign_guests, source: :guest

  has_many :campaign_members, dependent: :destroy
  has_many :members, through: :campaign_members, source: :member

  belongs_to :member

  after_save :set_campaign_poll

  accepts_nested_attributes_for :poll

  self.per_page = 10
  
  def set_campaign_poll
    # if self.poll_ids.present?
    #   poll_id = self.poll_ids.class == Array ? self.poll_ids.delete_if{|e| e == "" } : self.poll_ids.split(",").collect{|id| id.to_i }.delete_if {|e| e == "" }
    #   Poll.where("id IN (?)", poll_id).each do |poll|
    #     poll.update(campaign_id: id)
    #   end
    # end

    if self.poll_id.present?
      Poll.find(self.poll_id).update_attributes!(campaign_id: id)
    end
  end

  # def check_campaign_poll
  #   old_poll_ids = polls.pluck(:id)
  #   edit_poll_ids = poll_ids.class == Array ? poll_ids.delete_if {|e| e == "" } : poll_ids.split(",").collect{|id| id.to_i }.delete_if {|e| e == "" }

  #   old_poll_ids.each do |pid|
  #     Poll.find(pid).update_attributes!(campaign_id: nil) unless edit_poll_ids.include?(pid)
  #   end

  #   edit_poll_ids.each do |pid|
  #     Poll.find(pid).update(campaign_id: id) unless old_poll_ids.include?(pid)
  #   end
  # end

  def prediction(member_id)
    sample = (begin_sample..end_sample).to_a.sample
    puts "your lucky : #{sample}"
    if expire < Time.now
      puts "Campaign was expired"
      message = "Expired"
    elsif used >= limit
      puts "This campaign is limit."
      message = "Limited"
    elsif campaign_members.find_by_member_id(member_id)
      puts "used to redeem."
      message = "Used"
    else
      if sample % end_sample == 0
        @campaign = campaign_members.create!(member_id: member_id, luck: true, serial_code: generate_serial_code)
        increment!(:used)
      else
        @campaign = campaign_members.create!(member_id: member_id, luck: false)
      end
    end
    [@campaign, message]
  end

  def generate_serial_code
    return id.to_s + Time.now.to_i.to_s
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
