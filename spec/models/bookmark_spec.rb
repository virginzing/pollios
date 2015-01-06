require 'rails_helper'

RSpec.describe Bookmark, :type => :model do
  it { should belong_to(:member) }
  it { should validate_presence_of(:member_id) }
  it { should validate_uniqueness_of(:member_id).scoped_to(:bookmarkable_id) }
end
