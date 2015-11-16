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

class HistoryVote < ActiveRecord::Base

  include HistoryVoteAdmin

  belongs_to :member, touch: true, counter_cache: true
  belongs_to :poll
  belongs_to :poll_series
  belongs_to :choice
  
  store_accessor :data_analysis

  validates :poll_id, :member_id, :choice_id, presence: true

  scope :member_voted_poll, -> (member_id, poll_id) { where(member_id: member_id).where(poll_id: poll_id) }

  default_scope { order("#{table_name}.id desc") }

  %w[gender province].each do |key|
    scope "has_#{key}", lambda { |value| where("data_analysis @> hstore(?,?)", key, value) }
  end

  def self.get_gender_analysis(poll_id, choice_id, gender_type)
    HistoryVote.where("poll_id = ? AND choice_id = ?", poll_id, choice_id).has_gender(gender_type)
  end

end