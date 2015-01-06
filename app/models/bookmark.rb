class Bookmark < ActiveRecord::Base
  belongs_to :member
  belongs_to :bookmark, polymorphic: true
end
