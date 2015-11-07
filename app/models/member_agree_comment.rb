# == Schema Information
#
# Table name: member_agree_comments
#
#  id         :integer          not null, primary key
#  member_id  :integer
#  comment_id :integer
#  created_at :datetime
#  updated_at :datetime
#

class MemberAgreeComment < ActiveRecord::Base
  belongs_to :member
  belongs_to :comment
end
