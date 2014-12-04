require 'rails_helper'

RSpec.describe UnSeePoll, :type => :model do
  it { should belong_to(:member) }
  it { should belong_to(:poll) }
  it { should have_db_index([:member_id, :poll_id]).unique }


  describe ".get_my_unsee" do
    let!(:member) {  create(:member) }
    let!(:poll) { create(:poll, member: member) }
    let!(:un_see_poll) { create(:un_see_poll, member: member, poll: poll) }

    it "return list of poll which do unsee" do
      list_un_see = UnSeePoll.where(member_id: member.id)

      expect(UnSeePoll.get_my_unsee(member.id)).to eq(list_un_see)    
    end

  end
end
