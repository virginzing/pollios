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

FactoryGirl.define do
  factory :group_member do
    active true
    is_master false
    notification true

    trait :admin do
      is_master true
    end

    trait :pending do
      active false
    end

    after(:create) do |group_member, _|
      FlushCached::Group.new(group_member.group).clear_list_members
      FlushCached::Group.new(group_member.group).clear_list_requests
    end
  end

end
