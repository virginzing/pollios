# == Schema Information
#
# Table name: hidden_polls
#
#  id         :integer          not null, primary key
#  member_id  :integer
#  poll_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class HiddenPoll < ActiveRecord::Base
  belongs_to :member
  belongs_to :poll


  def self.my_hidden_poll(member_id)
    hidden_poll = where("member_id = ?", member_id).pluck(:poll_id)
  end

end
