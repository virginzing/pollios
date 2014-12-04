require 'rails_helper'

RSpec.describe SaveForLater, :type => :model do
  it { should belong_to(:member) }
  it { should belong_to(:poll) }
  it { should have_db_index([:member_id, :poll_id]).unique }
end
