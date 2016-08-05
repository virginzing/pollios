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

class MemberRecentRequest < ActiveRecord::Base
  belongs_to :member
  belongs_to :recent, polymorphic: true
end
