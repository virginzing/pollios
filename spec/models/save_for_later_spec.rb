require 'rails_helper'

RSpec.describe SaveForLater, :type => :model do
  it { should belong_to(:member) }
  it { should belong_to(:poll) }
  it { should have_db_index([:member_id, :poll_id]).unique }

  it { should validate_presence_of(:member_id) }
  it { should validate_presence_of(:poll_id) }
  
end
