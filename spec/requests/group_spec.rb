require 'rails_helper'

RSpec.describe "Group" do

  let!(:member) { create(:member) }
  let!(:group) { create(:group) }
  let!(:group_member) { create(:group_member, member: member, group: group) }

  let!(:poll) { create(:poll, member: member) }
  let!(:poll_group) { create(:poll_group, poll: poll, group: group, member: member) }

  it "return 1 group" do
    expect(Group.count).to eq(1)
  end

  it "return 1 group of member" do
    expect(GroupMember.count).to eq(1)
  end

  it "return 1 poll in group" do
    expect(PollGroup.count).to eq(1)
  end

  describe "GET /group/:id/polls" do
      
    before do
      get "/group/#{group.id}/polls.json", { member_id: member.id, api_version: 6 }, { "Accept" => "application/json" }
    end

    it "success" do
      expect(response).to be_success 
    end

    it "return OK" do
      expect(json["response_status"]).to eq("OK")
    end

    it "return 1 poll in group" do
      expect(json["timeline_polls"].size).to eq(1)
    end

    it "have key such as next_cursor" do
      expect(json.has_key?("next_cursor")).to be true
    end
  end

  describe "GET /group/:id/members" do
    before do
      get "/group/#{group.id}/members.json", { member_id: member.id }, { "Accept" => "application/json" }
    end

    it "success" do
      expect(response).to be_success
    end

    it "return OK" do
      expect(json["response_status"]).to eq("OK")
    end

    it "return key of active" do
      expect(json["member_group"]["active"].nil?).to be false
    end

    it "return key of pending" do
      expect(json["member_group"]["pending"].nil?).to be false
    end

    it "return key of request" do
      expect(json["member_group"]["request"].nil?).to be false
    end
  end


  describe "description" do
    
  end

end