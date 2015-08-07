# == Schema Information
#
# Table name: member_un_recomments
#
#  id             :integer          not null, primary key
#  member_id      :integer
#  unrecomment_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class MemberUnRecomment < ActiveRecord::Base
  belongs_to :member
end
