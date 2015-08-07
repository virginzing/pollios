# == Schema Information
#
# Table name: collection_poll_series
#
#  id                        :integer          not null, primary key
#  title                     :string(255)
#  company_id                :integer
#  sum_view_all              :integer          default(0)
#  sum_vote_all              :integer          default(0)
#  questions                 :string(255)      default([]), is an Array
#  created_at                :datetime
#  updated_at                :datetime
#  feedback_recurring_id     :integer
#  recurring_status          :boolean          default(TRUE)
#  recurring_poll_series_set :string(255)      default([]), is an Array
#  main_poll_series          :string(255)      default([]), is an Array
#  feedback_status           :boolean          default(TRUE)
#  campaign_id               :integer
#

FactoryGirl.define do
  factory :collection_poll_series do
    title "MyString"
    company nil
    sum_view_all 1
    sum_vote_all 1
  end

end
