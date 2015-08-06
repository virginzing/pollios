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

class CollectionPollSeries < ActiveRecord::Base

  belongs_to :company
  belongs_to :feedback_recurring
  belongs_to :campaign
  
  has_many :collection_poll_series_branches, dependent: :destroy
  has_many :branches, through: :collection_poll_series_branches, source: :branch


  def self.update_sum_vote(poll_series)
    poll_series.collection_poll_series.increment!(:sum_vote_all) if poll_series.feedback
  end

  def self.update_sum_view(poll_series)
    poll_series.collection_poll_series.increment!(:sum_view_all) if poll_series.feedback
  end

end
