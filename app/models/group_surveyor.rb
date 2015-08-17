# == Schema Information
#
# Table name: group_surveyors
#
#  id         :integer          not null, primary key
#  group_id   :integer
#  member_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

class GroupSurveyor < ActiveRecord::Base
  belongs_to :group
  belongs_to :member
end
