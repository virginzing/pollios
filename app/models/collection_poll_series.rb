class CollectionPollSeries < ActiveRecord::Base
  belongs_to :company
  has_many :collection_poll_series_branches, dependent: :destroy
  has_many :branches, through: :collection_poll_series_branches, source: :branch


  def self.update_sum_vote(poll_series)
    poll_series.collection_poll_series.increment!(:sum_vote_all)
  end

  def self.update_sum_view(poll_series)
    poll_series.collection_poll_series.increment!(:sum_view_all)
  end

end