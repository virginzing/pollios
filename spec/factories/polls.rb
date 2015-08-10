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
#  start_date              :datetime         default(2014-02-03 15:36:16 UTC)
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
#  qr_only                 :boolean
#  require_info            :boolean
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
    title Faker::Lorem.sentence
    type_poll :binary
    status_poll :gray
    in_group false
    public false
    expire_date Time.zone.now + 1.weeks
    expire_status false

    trait :not_allow_comment do
      allow_comment false
    end
  end

  factory :faker_test_poll, class: Poll do
    title Faker::Lorem.sentence
    type_poll :binary
    status_poll :gray
    in_group false
    public false
    expire_date Time.zone.now + 1.weeks
    expire_status false
  end


  # This should cause some problem
  factory :create_poll, class: Poll do
    title "ทดสอบ #eiei #nut"
    in_group false
    choices ["yes", "no"]
    type_poll "binary"
  end

  factory :create_poll_public, class: Poll do
    title "Poll Public"
    expire_within 2
    choices ["yes", "no"]
    type_poll "binary"
    is_public true
  end

  factory :story, class: Poll do
    member
    title Faker::Lorem.sentence
    public false
    allow_comment true

    factory :poll_with_choices do
      transient do
        choices_count 2
      end

      after(:create) do |poll, evaluator|
        create_list(:choice, evaluator.choices_count, poll: poll)
      end
    end

    trait :is_public do
      public true
    end

    trait :disable_comment do
      allow_comment false
    end

    factory :poll_to_public,   traits: [:is_public]
    factory :poll_that_disable_comment, traits: [:disable_comment]
  end

  factory :poll_required, class: Poll do
    member
    title Faker::Lorem.sentence
    public false
    allow_comment true
    creator_must_vote true
    type_poll "freeform"
  end

end
