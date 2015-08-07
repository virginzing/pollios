# == Schema Information
#
# Table name: history_vote_guests
#
#  id         :integer          not null, primary key
#  guest_id   :integer
#  poll_id    :integer
#  choice_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

class HistoryVoteGuest < ActiveRecord::Base
  belongs_to :guest
  belongs_to :poll
end
