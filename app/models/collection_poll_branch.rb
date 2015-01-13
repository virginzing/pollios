class CollectionPollBranch < ActiveRecord::Base
  belongs_to :branch
  belongs_to :collection_poll
end
