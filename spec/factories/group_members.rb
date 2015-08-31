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
    notification true
    is_master true

    trait :is_admin do
    	is_master true
    end

    trait :is_member do
    	is_master false 
    end

    trait :is_active do
    	active true
    end

    trait :is_pending do
    	active false
    end

    factory :group_member_that_is_admin, traits: [:is_admin]
    factory :group_member_that_is_member, traits: [:is_member]
  	factory :group_member_that_is_active, traits: [:is_active]
  	factory :group_member_that_is_pending, traits: [:is_pending]

  end

end
