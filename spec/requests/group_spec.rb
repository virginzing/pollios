require 'rails_helper'

RSpec.describe "Group" do

  let!(:member) { create(:member) }
  let!(:friend) { create(:member, fullname: "Friend Nut", email: "friend_nut@gmail.com") }
  let!(:group) { create(:group) }
  let!(:group_member) { create(:group_member, member: member, group: group, active: true, is_master: true) }

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
      expect(json["active"].nil?).to be false
    end

    it "return key of pending" do
      expect(json["pending"].nil?).to be false
    end

    it "return key of request" do
      expect(json["request"].nil?).to be false
    end
  end


  describe "POST /group/:id/edit_group" do
    before do
      post "/group/#{group.id}/edit_group.json", { member_id: member.id, name: "test name", description: "test description" }, { "Accept" => "application/json" }
    end

    it "success" do
      expect(json["response_status"]).to eq("OK")
    end

    it "name of group is test name" do
      expect(group.reload.name).to eq("test name")
    end

    it "description of group is test description" do
      expect(group.reload.description).to eq("test description")
    end

  end

  describe "POST /group/:id/promote_admin" do

    before do
      create(:group_member, member: friend, group: group, is_master: true, active: true)
      post "/group/#{group.id}/promote_admin.json", { friend_id: friend.id, member_id: member.id, admin: true }, { "Accept" => "application/json" }
    end

    it "success" do
      expect(json["response_status"]).to eq("OK")
    end

    it "set admin to member" do
      group_member = GroupMember.find_by(member: member, group: group)
      expect(group_member.is_master).to be true
    end
  end

  describe "POST /group/:id/kick_member" do
    before do
      create(:group_member, member: friend, group: group, active: true)
      post "/group/#{group.id}/kick_member.json", { member_id: member.id, friend_id: friend.id }, { "Accept" => "application/json" }
    end

    it "success" do
      expect(json["response_status"]).to eq("OK")
    end

    it "remain 1 people in group" do
      expect(group.group_members.count).to eq(1)
    end
  end

  describe "POST /group/:id/invite" do
    before do
      post "/group/#{group.id}/invite.json", { member_id: member.id, friend_id: friend.id }, { "Accept" => "application/json" }
    end

    it "success" do
      expect(json["response_status"]).to eq("OK")
    end

    it "have 1 record to active is false" do
      group_member = GroupMember.find_by(member: friend, group: group, active: false)
      expect(group_member.present?).to be true
    end
  end

  describe "POST /group/:id/accept" do
    before do
      create(:group_member, member: friend, group: group, active: false)
      post "/group/#{group.id}/accept.json", { member_id: friend.id }, { "Accept" => "application/json" }
    end

    it "success" do
      expect(json["response_status"]).to eq("OK")
    end

    it "can accept friend to group" do
      group_member = GroupMember.find_by(member: friend, group: group)
      expect(group_member.active).to be true
    end
  end

  describe "POST /group/:id/leave" do
    before do
      post "/group/#{group.id}/leave.json", { member_id: member.id }, { "Accept" => "application/json" }
    end

    it "success" do
      expect(json["response_status"]).to eq("OK")
    end

    it "remain 0 people in group" do
      expect(group.group_members.count).to eq(0)
    end
  end

  describe "POST /group/:id/request_group" do
    before do
      post "/group/#{group.id}/request_group.json", { member_id: friend.id }, { "Accept" => "application/json" }
    end

    it "success" do
      expect(json["response_status"]).to eq("OK")
    end

    it "have friend in record of request group" do
      expect(RequestGroup.find_by(member: friend, group: group, accepted: false).present?).to be true

      expect(json["waitting_approve"]).to be true
      expect(json["join_success"]).to be false
    end

    context "when group set need_approve is false" do

      let!(:group) { create(:group, name: "Thailand", need_approve: false, public: true) }

      let!(:someone) { create(:member, fullname: "test nut", email: "someone@gmail.com") }
      
      it "join group immediately" do
        post "/group/#{group.id}/request_group.json", { member_id: someone.id }, { "Accept" => "application/json" }

        expect(json["response_status"]).to eq("OK")

        expect(RequestGroup.count).to eq(0)

        expect(json["waitting_approve"]).to be false
        expect(json["join_success"]).to be true
      end
    
    end
  end

  describe "POST /group/:id/accept_request_group" do
    before do
      create(:request_group, member: friend, group: group, accepted: false)
      post "/group/#{group.id}/accept_request_group.json", { member_id: member.id, friend_id: friend.id }, { "Accept" => "application/json" }
    end

    it "success" do
      expect(json["response_status"]).to eq("OK")
    end

    it "set request group to accepted is true" do
      find_request_group = RequestGroup.find_by(member: friend, group: group, accepter_id: member.id)
      expect(find_request_group.accepted).to be true
    end

    it "add member to group" do
      find_group_member = GroupMember.find_by(member: friend, group: group, active: true)
      expect(find_group_member.present?).to be true
    end

  end

  describe "POST /group/:id/cancel_ask_join_group" do
    before do
      create(:request_group, member: friend, group: group, accepted: false)
      post "/group/#{group.id}/cancel_ask_join_group.json", { member_id: friend.id }, { "Accept" => "application/json" }
    end

    it "success" do
      expect(json["response_status"]).to eq("OK")
    end

    it "delete to request group" do
      find_request_group = RequestGroup.find_by(member: friend, group: group, accepted: false)
      expect(find_request_group.nil?).to be true
    end
  end

  # describe "POST /group/:id/public_id" do
  #   let!(:second_group) { create(:group, name: "Second group" ) }

  #   before do
  #     post "/group/#{group.id}/public_id.json", { member_id: member.id, public_id: "123" }, { "Accept" => "application/json" }
  #   end

  #   it "success" do
  #     expect(json["response_status"]).to eq("OK")
  #   end

  #   it "set new public_id" do
  #     expect(group.reload.public_id).to eq("123")
  #   end

  #   it "validate uniqueness of public_id" do
  #     post "/group/#{second_group.id}/public_id.json", { member_id: member.id, public_id: "123" }, { "Accept" => "application/json" }
  #     expect(json["response_status"]).to eq("ERROR")
  #     expect(json["response_message"]).to eq("Public ID has already been taken")
  #   end
  # end

  describe "POST /group/:id/set_public" do
    let!(:group) {  create(:group, name: "Wow Group", public: false) }
    let!(:second_group) {  create(:group, name: "second group", public: true) }

    it "success" do
      post "/group/#{group.id}/set_public.json", { member_id: member.id, public: true }, { "Accept" => "application/json" }
      expect(json["response_status"]).to eq("OK")
    end

    it "set public to true" do
      expect(group.public).to be false
      post "/group/#{group.id}/set_public.json", { member_id: member.id, public: true }, { "Accept" => "application/json" }
      expect(group.reload.public).to be true
    end

    it "set public to false" do
      expect(second_group.public).to eq(true)
      post "/group/#{second_group.id}/set_public.json", { member_id: member.id, public: false }, { "Accept" => "application/json" }
      expect(second_group.reload.public).to be false
    end

    it "set public_id" do
      post "/group/#{second_group.id}/set_public.json", { member_id: member.id, public: true, public_id: "1234567" }, { "Accept" => "application/json" }
      expect(second_group.reload.public).to be true
      expect(second_group.reload.public_id).to eq("1234567")
    end
  end


end