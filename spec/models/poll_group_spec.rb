# == Schema Information
#
# Table name: poll_groups
#
#  id               :integer          not null, primary key
#  poll_id          :integer
#  group_id         :integer
#  created_at       :datetime
#  updated_at       :datetime
#  share_poll_of_id :integer          default(0)
#  member_id        :integer
#  deleted_at       :datetime
#  deleted_by_id    :integer
#

require 'rails_helper'

RSpec.describe PollGroup, :type => :model do

end
