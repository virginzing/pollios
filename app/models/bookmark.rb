# == Schema Information
#
# Table name: bookmarks
#
#  id                :integer          not null, primary key
#  member_id         :integer
#  bookmarkable_id   :integer
#  bookmarkable_type :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#

class Bookmark < ActiveRecord::Base
  belongs_to :member
  belongs_to :bookmarkable, polymorphic: true

  validates_presence_of :member_id

  validates_uniqueness_of :member_id, scope: :bookmarkable_id
end
