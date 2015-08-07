# == Schema Information
#
# Table name: guests
#
#  id         :integer          not null, primary key
#  udid       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Guest < ActiveRecord::Base
  has_many :history_vote_guests, dependent: :destroy
  has_many :history_view_guests, dependent: :destroy
  has_many :campaign_guests, dependent: :destroy
  has_many :campaigns, through: :campaign_guests, source: :campaign

  def self.try_out_app(udid)
    where(udid).first_or_create!
  end

  def list_voted?(history_voted_guest, poll_id)
    history_voted_guest.each do |poll_choice|
      if poll_choice.first == poll_id
        return Hash["voted" => true, "choice_id" => poll_choice[1]]
      end
    end
    Hash["voted" => false]
  end

  def list_viewed?(history_viewed_guest, poll_id)
    history_viewed_guest.include?(poll_id)
  end

end
