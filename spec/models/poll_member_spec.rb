# == Schema Information
#
# Table name: poll_members
#
#  id               :integer          not null, primary key
#  member_id        :integer
#  poll_id          :integer
#  share_poll_of_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#  public           :boolean
#  series           :boolean
#  expire_date      :datetime
#  in_group         :boolean          default(FALSE)
#  poll_series_id   :integer          default(0)
#

require 'rails_helper'

RSpec.describe PollMember, :type => :model do

end
