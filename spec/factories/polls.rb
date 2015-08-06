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

  factory :poll do |f|
    f.title Faker::Lorem.sentence
    f.type_poll :binary
    f.status_poll :gray
    f.in_group false
    f.public false
    f.expire_date Time.zone.now + 1.weeks
    f.expire_status false
  end

  factory :faker_test_poll, class: Poll do |f|
    f.title Faker::Lorem.sentence
    f.type_poll :binary
    f.status_poll :gray
    f.in_group false
    f.public false
    f.expire_date Time.zone.now + 1.weeks
    f.expire_status false
  end

  # factory :create_poll, class: Poll do
  #   title "ทดสอบ #eiei #nut"
  #   in_group false
  #   choices ["yes", "no"]
  #   type_poll "binary"
  # end

  # factory :create_poll_public, class: Poll do
  #   title "Poll Public"
  #   expire_within 2
  #   choices ["yes", "no"]
  #   type_poll "binary"
  #   is_public true
  # end

end
