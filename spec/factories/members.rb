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
    transient do
      friend_limit 1000

      notification do
        Hashie::Mash.new(
          public: :true, \
          group: :true, \
          friend: :true, \
          watch_poll: :true, \
          request: :true, \
          join_group: :true \
        )
      end
    end

    fullname { Faker::Name.name }
    email { Faker::Internet.email }
    with_apn_devices

    after(:create) do |member, evaluator|
      member.update(friend_limit: evaluator.friend_limit, notification: evaluator.notification)
    end

    trait :in_company do
      company
    end

    trait :is_celebrity do
      member_type 1
    end

    trait :in_groups do
      transient do
        group_count { Faker::Number.between(3, 5) }
        groups { create_list(:group, group_count) }
        
        admin false
        group_member_factory { admin ? :group_member_admin : :group_member }
      end

      after(:create) do |member, evaluator|
        evaluator.groups.each do |group|
          create(evaluator.group_member_factory, member: member, group: group)
        end
      end
    end

    trait :sends_requests_to_group do
      transient do
        group_count { Faker::Number.between(3, 5) }
        groups { create_list(:group, group_count) }
      end

      after(:create) do |member, evaluator|
        evaluator.groups.each do |group|
          create(:request_group, member: member, group: group)
        end
      end
    end

    trait :custom_notification do
      transient do
        public_notification :false
        group_notification :false
        friend_notification :false
        watch_poll_notification :false
        request_notification :false
        join_group_notification :false

        notification do
          Hashie::Mash.new(
            public: public_notification.to_s, \
            group: group_notification.to_s, \
            friend: friend_notification.to_s, \
            watch_poll: watch_poll_notification.to_s, \
            request: request_notification.to_s, \
            join_group: join_group_notification.to_s \
          )
        end
      end
    end

    trait :default_notification do
      custom_notification

      transient do
        public_notification :false
        group_notification :true
        friend_notification :true
        watch_poll_notification :true
        request_notification :true
        join_group_notification :false
      end
    end

    trait :disabled_notification do
      custom_notification
    end

    trait :with_apn_devices do
      transient do
        device_count { Faker::Number.between(1, 2) }
        device_factory :apn_device
      end

      after(:create) do |member, evaluator|
        create_list(evaluator.device_factory, evaluator.device_count, member: member)
      end
    end

    factory :member_who_sends_join_requests, traits: [:sends_requests_to_group]
    factory :member_in_groups, traits: [:in_groups]
    factory :company_member, traits: [:in_company]
    factory :celebrity_member, traits: [:is_celebrity]
  end

  # factory :sequence_member, class: Member do
  #   fullname { Faker::Name.name }

  #   sequence(:id) { |n| n+101 }
  #   sequence(:email) { |n| "mail#{n+1}@mail.com" }
  # end

end
