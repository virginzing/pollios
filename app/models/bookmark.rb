class Bookmark < ActiveRecord::Base
  belongs_to :member
  belongs_to :bookmarkable, polymorphic: true

  validates_presence_of :member_id

  validates_uniqueness_of :member_id, scope: :bookmarkable_id
end
