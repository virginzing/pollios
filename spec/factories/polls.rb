# == Schema Information
#
# Table name: polls
#
#  id                      :integer          not null, primary key
#  member_id               :integer
#  title                   :text
#  public                  :boolean          default(FALSE)
#  vote_all                :integer          default(0)
#  created_at              :datetime
#  updated_at              :datetime
#  photo_poll              :string(255)
#  expire_date             :datetime
#  view_all                :integer          default(0)
#  start_date              :datetime         default(2016-09-05 10:01:35 UTC)
#  series                  :boolean          default(FALSE)
#  poll_series_id          :integer
#  choice_count            :integer
#  campaign_id             :integer
#  share_count             :integer          default(0)
#  recurring_id            :integer          default(0)
#  in_group_ids            :string(255)
#  qrcode_key              :string(255)
#  type_poll               :integer
#  report_count            :integer          default(0)
#  status_poll             :integer          default(0)
#  allow_comment           :boolean          default(TRUE)
#  comment_count           :integer          default(0)
#  member_type             :string(255)
#  qr_only                 :boolean          default(FALSE)
#  require_info            :boolean          default(FALSE)
#  expire_status           :boolean          default(FALSE)
#  creator_must_vote       :boolean          default(TRUE)
#  in_group                :boolean          default(FALSE)
#  show_result             :boolean          default(TRUE)
#  order_poll              :integer          default(1)
#  quiz                    :boolean          default(FALSE)
#  notify_state            :integer          default(0)
#  notify_state_at         :datetime
#  priority                :integer
#  thumbnail_type          :integer          default(0)
#  comment_notify_state    :integer          default(0)
#  comment_notify_state_at :datetime
#  draft                   :boolean          default(FALSE)
#  system_poll             :boolean          default(FALSE)
#  deleted_at              :datetime
#  close_status            :boolean          default(FALSE)
#

FactoryGirl.define do

  factory :poll, class: Poll do
    transient do
      choice_count { Faker::Number.between(2, 5) }
    end

    member
    title { Faker::Lorem.sentence }
    choice_params { Faker::Lorem.words(choice_count) }
    allow_comment true
    expire_date { Time.zone.now + 100.years }

    after(:create) do |poll, evaluator|
      create_list(:choice, evaluator.choice_count, poll: poll)
    end

    trait :with_type_poll do
      type_poll :binary
    end

    trait :with_status_poll do
      status_poll :gray
    end

    trait :with_in_group do
      in_group false
    end

    trait :public do
      public true
    end

    trait :with_expire_date do
      expire_date Time.zone.now + 1.weeks
    end

    trait :with_expire_status do
      expire_status false
    end

    trait :with_creator_must_vote do
      creator_must_vote true
    end

    trait :not_allow_comment do
      allow_comment false
    end

    factory :public_poll, traits: [:public]
  end
end
