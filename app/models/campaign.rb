class Campaign < ActiveRecord::Base
  mount_uploader :photo_campaign, PhotoCampaignUploader
  belongs_to :member

  validates :name, :begin_sample, :end_sample, :limit, presence: true
  has_many :polls
  has_many :poll_series

  has_many :campaign_guests
  has_many :guests, through: :campaign_guests, source: :guest

  has_many :campaign_members
  has_many :members, through: :campaign_members, source: :member

  def prediction(member_id)
    sample = (begin_sample..end_sample).to_a.sample
    puts "your lucky : #{sample}"
    if used < limit
      if sample % end_sample == 0
        unless campaign_members.find_by_member_id(member_id)
          campaign_members.create!(member_id: member_id, luck: true, serial_code: generate_serial_code)
          increment!(:used)
        end
      else
        unless campaign_members.find_by_member_id(member_id)
          campaign_members.create!(member_id: member_id, luck: false)
        end
      end
    else
      puts "This campaign is limit."
    end
  end

  def generate_serial_code
    return "POLLIOSCODE" + id.to_s + Time.now.to_i.to_s
  end
  
end
