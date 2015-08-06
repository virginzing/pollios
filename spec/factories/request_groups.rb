# == Schema Information
#
# Table name: request_groups
#
#  id          :integer          not null, primary key
#  member_id   :integer
#  group_id    :integer
#  created_at  :datetime
#  updated_at  :datetime
#  accepter_id :integer
#  accepted    :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :request_group do
    group nil
    member nil
  end

end
