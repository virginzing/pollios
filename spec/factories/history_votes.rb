# == Schema Information
#
# Table name: history_votes
#
#  id             :integer          not null, primary key
#  member_id      :integer
#  poll_id        :integer
#  choice_id      :integer
#  created_at     :datetime
#  updated_at     :datetime
#  poll_series_id :integer          default(0)
#  data_analysis  :hstore
#  surveyor_id    :integer
#  show_result    :boolean          default(FALSE)
#

require 'faker'

FactoryGirl.define do

  factory :history_vote do

  end

  factory :history_vote_required, class: HistoryVote do
    member nil
    poll nil
    choice nil
    show_result true
  end

end
