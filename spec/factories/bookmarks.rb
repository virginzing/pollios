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

FactoryGirl.define do
  factory :bookmark do

  end

  factory :bookmark_required, class: Bookmark do
    member nil
    bookmarkable_id nil
    bookmarkable_type nil
  end

end
