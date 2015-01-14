class CollectionPoll < ActiveRecord::Base
  belongs_to :company

  has_many :collection_poll_branches, dependent: :destroy
  has_many :branches, through: :collection_poll_branches, source: :branch

end
