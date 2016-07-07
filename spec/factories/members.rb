# == Schema Information
#
# Table name: members
#
#  id                         :integer          not null, primary key
#  fullname                   :string(255)
#  username                   :string(255)
#  avatar                     :string(255)
#  email                      :string(255)
#  created_at                 :datetime
#  updated_at                 :datetime
#  friend_limit               :integer
#  member_type                :integer          default(0)
#  key_color                  :string(255)
#  cover                      :string(255)
#  description                :text
#  sync_facebook              :boolean          default(FALSE)
#  report_power               :integer          default(1)
#  anonymous                  :boolean          default(FALSE)
#  anonymous_public           :boolean          default(FALSE)
#  anonymous_friend_following :boolean          default(FALSE)
#  anonymous_group            :boolean          default(FALSE)
#  report_count               :integer          default(0)
#  status_account             :integer          default(1)
#  first_signup               :boolean          default(TRUE)
#  point                      :integer          default(0)
#  subscription               :boolean          default(FALSE)
#  subscribe_last             :datetime
#  subscribe_expire           :datetime
#  bypass_invite              :boolean          default(FALSE)
#  auth_token                 :string(255)
#  approve_brand              :boolean          default(FALSE)
#  approve_company            :boolean          default(FALSE)
#  gender                     :integer
#  province                   :integer
#  birthday                   :date
#  interests                  :text
#  salary                     :integer
#  setting                    :hstore
#  update_personal            :boolean          default(FALSE)
#  notification_count         :integer          default(0)
#  request_count              :integer          default(0)
#  cover_preset               :string(255)      default("0")
#  register                   :integer          default(0)
#  slug                       :string(255)
#  public_id                  :string(255)
#  waiting                    :boolean          default(FALSE)
#  created_company            :boolean          default(FALSE)
#  first_setting_anonymous    :boolean          default(TRUE)
#  receive_notify             :boolean          default(TRUE)
#  fb_id                      :string(255)
#  blacklist_last_at          :datetime
#  blacklist_count            :integer          default(0)
#  ban_last_at                :datetime
#  sync_fb_last_at            :datetime
#  list_fb_id                 :string(255)      default([]), is an Array
#  show_recommend             :boolean          default(FALSE)
#  notification               :hstore           default({}), not null
#  show_search                :boolean          default(TRUE)
#  polls_count                :integer          default(0)
#  history_votes_count        :integer          default(0)
#

require 'faker'

FactoryGirl.define do

  factory :member do
    fullname { Faker::Name.name }
    email { Faker::Internet.email }

    trait :in_company do
      company
    end

    trait :is_celebrity do
      member_type 1 
    end

    factory :company_member, traits: [:in_company]
    factory :celebrity_member, traits: [:is_celebrity]
  end

  after(:create) do |member|
    member.update(friend_limit: 4)
  end

  # factory :sequence_member, class: Member do
  #   fullname { Faker::Name.name }

  #   sequence(:id) { |n| n+101 }
  #   sequence(:email) { |n| "mail#{n+1}@mail.com" }
  # end

end
