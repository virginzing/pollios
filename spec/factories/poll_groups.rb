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

FactoryGirl.define do
  factory :poll_group do
    share_poll_of_id 0
    poll nil
    group nil
    member nil
  end

end
