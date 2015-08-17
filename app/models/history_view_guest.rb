# == Schema Information
#
# Table name: history_view_guests
#
#  id         :integer          not null, primary key
#  guest_id   :integer
#  poll_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class HistoryViewGuest < ActiveRecord::Base
  belongs_to :guest
  belongs_to :poll
end
