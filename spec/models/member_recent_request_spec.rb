# == Schema Information
#
# Table name: member_recent_requests
#
#  id          :integer          not null, primary key
#  member_id   :integer
#  recent_id   :integer
#  recent_type :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

RSpec.describe MemberRecentRequest, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
