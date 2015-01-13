class CollectionPoll < ActiveRecord::Base
  belongs_to :company
  has_many :grouppings, dependent: :destroy
  has_many :collection_poll_branches, dependent: :destroy
  has_many :branches, through: :collection_poll_branches, source: :branch

  def self.update_sum_vote(poll_series)
    poll_series.groupping.collection_poll.increment!(:sum_vote_all) if poll_series.feedback
  end

  def self.update_sum_view(poll_series)
    poll_series.groupping.collection_poll.increment!(:sum_view_all) if poll_series.feedback
  end
end
