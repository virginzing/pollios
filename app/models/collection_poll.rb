class CollectionPoll < ActiveRecord::Base
  belongs_to :company
  has_many :grouppings, dependent: :destroy
end
