# == Schema Information
#
# Table name: suggest_groups
#
#  id         :integer          not null, primary key
#  group_id   :integer
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :suggest_group do
    group_id 1
  end

end
