# == Schema Information
#
# Table name: history_promote_polls
#
#  id         :integer          not null, primary key
#  member_id  :integer
#  poll_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe HistoryPromotePoll, type: :model do

end
