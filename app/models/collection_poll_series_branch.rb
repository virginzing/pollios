class CollectionPollSeriesBranch < ActiveRecord::Base
  belongs_to :collection_poll_series
  belongs_to :branch
  belongs_to :poll_series
end