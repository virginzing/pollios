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

require 'rails_helper'

RSpec.describe Bookmark, :type => :model do
  it { should belong_to(:member) }
  it { should validate_presence_of(:member_id) }
  it { should validate_uniqueness_of(:member_id).scoped_to(:bookmarkable_id) }
end
