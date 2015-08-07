# == Schema Information
#
# Table name: group_members
#
#  id           :integer          not null, primary key
#  member_id    :integer
#  group_id     :integer
#  is_master    :boolean          default(TRUE)
#  created_at   :datetime
#  updated_at   :datetime
#  active       :boolean          default(FALSE)
#  invite_id    :integer
#  notification :boolean          default(TRUE)
#

require 'rails_helper'

RSpec.describe GroupMember, :type => :model do

end
