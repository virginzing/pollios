require 'rails_helper'

RSpec.describe "Friend" do

  let!(:member) { create(:member, fullname: "Nutkub", email: "nutkub@gmail.com") }
  let!(:friend) { create(:member, fullname: "Ning", email: "ning@gmail.com") }
  let!(:celebrity) { create(:celebrity) }

  let!(:group) { create(:group, public: true) }
  let!(:group_member) { create(:group_member, member: member, group: group, active: true, is_master: true) }
  let!(:group_friend) { create(:group_member, member: friend, group: group, active: true, is_master: true) }


  let!(:group_virtual) { create(:group, public: true, virtual_group: true) }
  let!(:group_member_virtual) { create(:group_member, member: member, group: group_virtual, active: true, is_master: true) }
  let!(:group_friend_virtual) { create(:group_member, member: friend, group: group_virtual, active: true, is_master: true) }


  describe "GET /friend/votes" do
    context 'of mine' do

      it "return list poll of voted" do
        get '/friend/votes.json', { member_id: member.id, friend_id: member.id, api_version: 6 }, { "Accept" => "application/json" }

        expect(response).to be_success

        expect(json["response_status"]).to eq("OK")

        expect(json["timeline_polls"].size).to eq(0)
      end

    end


    context 'of friend' do
      
      it "return list poll of voted" do
        get '/friend/votes.json', { member_id: member.id, friend_id: friend.id, api_version: 6 }, { "Accept" => "application/json" }

        expect(response).to be_success

        expect(json["response_status"]).to eq("OK")
      end
    end

  end

  describe "GET /friend/save_poll_later" do
    context 'of mine' do
      
      it "return list poll of saved" do
        get '/friend/save_poll_later.json', { member_id: member.id, friend_id: friend.id, api_version: 6 }, { "Accept" => "application/json" }
      
        expect(response).to be_success

        expect(json["response_status"]).to eq("OK")
      end

    end
  end

  describe "GET /friend/profile" do
    context 'of mine' do
      
      it "return detail profile" do
        get '/friend/profile.json', { member_id: member.id, friend_id: member.id }, { "Accept" => "application/json" }

        expect(response).to be_success
        expect(json["response_status"]).to eq("OK") 
        expect(json.has_key?("status")).to be true
        expect(json.has_key?("activity")).to be true
        expect(json.has_key?("setting_default")).to be true
        expect(json.has_key?("count")).to be true
      end

    end

    context 'of friend' do

      it " return detail profile" do
        get '/friend/profile.json', { member_id: member.id, friend_id: friend.id }, { "Accept" => "application/json" }

        expect(response).to be_success
        expect(json["response_status"]).to eq("OK") 
        expect(json.has_key?("status")).to be true
        expect(json.has_key?("activity")).to be true
        expect(json.has_key?("setting_default")).to be false
        expect(json.has_key?("count")).to be false
      end
    end
  end

  describe "GET /friend/polls" do

    let!(:poll) { create(:poll, member: member) }
    let!(:poll_member) { create(:poll_member, poll: poll, member: member) }

    context 'of mine' do
      it "return list my poll" do
        get '/friend/polls.json', { member_id: member.id, friend_id: member.id, api_version: 6 }, { "Accept" => "application/json" }

        expect(response).to be_success
        expect(json["response_status"]).to eq("OK")
        expect(json["timeline_polls"].size).to eq(1)
        expect(json["next_cursor"]).to eq(0)
      end
    end

    context 'of friend' do
      let!(:poll_friend) { create(:poll, member: friend) }
      let!(:poll_member_friend) { create(:poll_member, poll: poll_friend, member: friend) }

      before do
        Friend.add_friend( {member_id: member.id, friend_id: friend.id})
        Friend.accept_or_deny_freind({member_id: friend.id, friend_id: member.id}, true)
      end

      it "return list friend poll" do
        get "/friend/polls.json", { member_id: member.id, friend_id: friend.id, api_version: 6 }, { "Accept" => "application/json" }

        expect(response).to be_success
        expect(json["response_status"]).to eq("OK")
        expect(json["timeline_polls"].size).to eq(1)
      end
    end
  end

  describe "GET /friend/bookmarks" do
    let!(:poll) { create(:poll, member: member) }

    context "of mine" do
      it "return list my bookmark" do
        create(:bookmark, member: member, bookmarkable: poll)

        get "/friend/bookmarks.json", { member_id: member.id, friend_id: member.id, api_version: 6 }, { "Accept" => "application/json" }
        expect(response).to be_success
        expect(json["response_status"]).to eq("OK")
      end
    end
  end


  describe "POST /friend/add_friend" do
    before do
      post "/friend/add_friend.json", { member_id: member.id, friend_id: friend.id }, { "Accept" => "application/json" }
    end

    it "success" do
      expect(response.status).to eq(201)
    end

    it "return response_status is OK" do
      expect(json["response_status"]).to eq("OK")
    end

    it "create to friend record by invite member" do
      find_member = Friend.find_by(follower: member, followed: friend, active: true, status: 0)
      expect(find_member.present?).to be true
    end

    it "create to friend recond by invitee friend" do
      find_friend = Friend.find_by(follower: friend, followed: member, active: true, status: 2)
      expect(find_friend.present?).to be true
    end

  end

  describe "POST /friend/accept" do
    context "normal" do
      before do
        @user_one = create(:friend, follower: member, followed: friend, active: true, status: 0)

        @user_two = create(:friend, follower: friend, followed: member, active: true, status: 2)

        post "/friend/accept.json", { member_id: friend.id, friend_id: member.id }, { "Accept" => "application/json" }
      end

      it "success" do
        expect(response.status).to eq(201)
      end

      it "be friend together" do
        expect(@user_one.reload.status).to eq("friend")
        expect(@user_two.reload.status).to eq("friend")
      end
    end

    context "it was canceling before it accepted" do
      before do
        @user_one = create(:friend, follower: member, followed: friend, active: true, status: 0)

        @user_two = create(:friend, follower: friend, followed: member, active: true, status: 2)
      end

      it "was canceling before accpeted" do
        @user_one.destroy
        @user_two.destroy

        post "/friend/accept.json", { member_id: friend.id, friend_id: member.id }, { "Accept" => "application/json" }
        expect(response.status).to eq(422)
        expect(json["response_status"]).to eq("ERROR")
      end

    end
  end

  describe "POST /friend/deny" do
    context "when denied by invitee" do
      before do
        @user_one = create(:friend, follower: member, followed: friend, active: true, status: 0)

        @user_two = create(:friend, follower: friend, followed: member, active: true, status: 2)

        post "/friend/deny.json", { member_id: friend.id, friend_id: member.id }, { "Accept" => "application/json" }
      end

      it "success" do
        expect(response.status).to eq(201)
      end

      it "cancel to add friend" do
        find_user_one = Friend.find_by(follower: member, followed: friend, active: true, status: 0)
        find_user_two = Friend.find_by(follower: friend, followed: member, active: true, status: 2)

        expect(find_user_one.nil?).to be true
        expect(find_user_two.nil?).to be true
      end
    end

    context "when denied by invite" do
      before do
        @user_one = create(:friend, follower: member, followed: friend, active: true, status: 0)
        @user_two = create(:friend, follower: friend, followed: member, active: true, status: 2)

        post "/friend/deny.json", { member_id: member.id, friend_id: friend.id }, { "Accept" => "application/json" }
      end

      it "success" do
        expect(response.status).to eq(201)
      end

      it "cancel to add friend" do
        find_user_one = Friend.find_by(follower: member, followed: friend, active: true, status: 0)
        find_user_two = Friend.find_by(follower: friend, followed: member, active: true, status: 2)

        expect(find_user_one.nil?).to be true
        expect(find_user_two.nil?).to be true
      end
    end

    context "when denined by invitee but invitee is following" do
      before do
        @user_one = create(:friend, follower: member, followed: friend, active: true, status: 0, following: false)
        @user_two = create(:friend, follower: friend, followed: member, active: true, status: 2, following: true)
      end

      it "success" do
        post "/friend/deny.json", { member_id: friend.id, friend_id: member.id }, { "Accept" => "application/json" }
        expect(response.status).to eq(201)
      end

      it "remain invitee that invitee following invite but he was cancelled by invitee" do
        post "/friend/deny.json", { member_id: friend.id, friend_id: member.id }, { "Accept" => "application/json" }
        find_user_one = Friend.find_by(follower: member, followed: friend, active: true, status: 0)
        find_user_two = Friend.find_by(follower: friend, followed: member, active: true, status: -1)

        expect(find_user_one.nil?).to eq(true)
        expect(find_user_two.present?).to eq(true)
      end

      it "remain invitee that invitee following invite but he was cancelled by invite" do
        post "/friend/deny.json", { member_id: member.id, friend_id: friend.id }, { "Accept" => "application/json" }

        find_user_one = Friend.find_by(follower: member, followed: friend, active: true, status: 0)
        find_user_two = Friend.find_by(follower: friend, followed: member, active: true, status: -1)

        expect(find_user_one.nil?).to eq(true)
        expect(find_user_two.present?).to eq(true)
      end
    end

    context "when following together" do
      before do
        @user_one = create(:friend, follower: member, followed: friend, active: true, status: 0, following: true)
        @user_two = create(:friend, follower: friend, followed: member, active: true, status: 2, following: true)
      end

      it "does something" do
        post "/friend/deny.json", { member_id: friend.id, friend_id: member.id }, { "Accept" => "application/json" }
        expect(response.status).to eq(201)
      end

      it "remain invite and invitee that following which was denied by invitee" do
        post "/friend/deny.json", { member_id: member.id, friend_id: friend.id }, { "Accept" => "application/json" }

        find_user_one = Friend.where(follower: member, followed: friend, active: true, status: -1, following: true).first
        find_user_two = Friend.where(follower: friend, followed: member, active: true, status: -1, following: true).first

        expect(find_user_one.present?).to eq(true)
        expect(find_user_two.present?).to eq(true)
      end

    end
  end

  describe "POST /friend/unfriend" do
    before do
      @user_one = create(:friend, follower: member, followed: friend, active: true, status: 1)
      @user_two = create(:friend, follower: friend, followed: member, active: true, status: 1)

      post "/friend/unfriend.json", { member_id: member.id, friend_id: friend.id }, { "Accept" => "application/json" }
    end

    it "success" do
      expect(response.status).to eq(201)
    end

    it "remove friend" do
      find_user_one = Friend.find_by(follower: member, followed: friend, active: true, status: 1)
      find_user_two = Friend.find_by(follower: friend, followed: member, active: true, status: 1)

      expect(find_user_one.nil?).to be true
      expect(find_user_two.nil?).to be true
    end

  end

  describe "POST /friend/block" do
    before do
      @user_one = create(:friend, follower: member, followed: friend, status: 1, active: true)
      @user_two = create(:friend, follower: friend, followed: member, status: 1, active: true)

      post "/friend/block.json", { member_id: member.id, friend_id: friend.id }, { "Accept" => "application/json" }
    end

    it "success" do
      expect(response.status).to eq(201)
    end

    it "block friend" do
      expect(@user_one.reload.block).to be true
      expect(@user_two.reload.visible_poll).to be false
    end
  end

  describe "POST /friend/unblock" do
    before do
      @user_one = create(:friend, follower: member, followed: friend, status: 1, active: true, block: true)
      @user_two = create(:friend, follower: friend, followed: member, status: 1, active: true, visible_poll: false)

      post "/friend/unblock.json", { member_id: member.id, friend_id: friend.id }, { "Accept" => "application/json" }
    end

    it "success" do
      expect(response.status).to eq(201)
    end

    it "unblock friend" do
      find_user_one = Friend.find_by(follower: member, followed: friend, active: true, status: 1, block: false)
      find_user_two = Friend.find_by(follower: friend, followed: member, active: true, status: 1, visible_poll: true)

      expect(find_user_one.reload.present?).to be true
      expect(find_user_two.reload.present?).to be true

    end
  end

  describe "POST /friend/following" do
    before do
      post "/friend/following.json", { member_id: member.id, friend_id: celebrity.id }, { "Accept" => "application/json" }
    end

    it "success" do
      expect(response.status).to eq(201)
    end

    it "can following celebrity" do
      find_following = Friend.find_by(follower: member, followed: celebrity, following: true, status: -1)
      expect(find_following.present?).to be true
    end
  end

  describe "POST /friend/unfollow" do
    before do
      create(:friend, follower: member, followed: celebrity, following: true, status: -1)
      post "/friend/unfollow.json", { member_id: member.id, friend_id: celebrity.id }, { "Accept" => "application/json" }
    end

    it "success" do
      expect(response.status).to eq(201)
    end

    it "can unfollow" do
      find_following = Friend.find_by(follower: member, followed: celebrity, following: true, status: -1)

      expect(find_following.nil?).to be true
    end
  end


  describe "GET /friend/groups" do
    context "my group" do
      before do
        get "/friend/groups.json", { member_id: member.id, friend_id: member.id }, { "Accept" => "application/json" }
      end

      it "success" do
        expect(json["response_status"]).to eq("OK")
      end

      it "have 1 group in list group of json format (non virtual)" do
        expect(json["groups"].size).to eq(1)
      end

      it "have 2 group of member" do
        expect(Member::ListGroup.new(member).active.size).to eq(2)
      end
    end

    context "friend" do
      before do
        get "/friend/groups.json", { member_id: member.id, friend_id: friend.id }, { "Accept" => "application/json" }
      end

      it "success" do
        expect(json["response_status"]).to eq("OK")
      end

      it "see 1 group in list group of friend (together group)" do
        expect(json["groups"].size).to eq(1)
      end

      it "have 2 group of friend (together group)" do
        expect(Friend::ListGroup.new(member, friend).together_group_of_friend.to_a.size).to eq(2)
      end

      it "have 1 group of friend (together group with non virtual)" do
        expect(Friend::ListGroup.new(member, friend).together_group_of_friend_non_virtual.to_a.size).to eq(1)
      end
    end

  end

  describe "GET /friend/collection_profile" do
    context "my profile" do
      before do
        get "/friend/collection_profile.json", { member_id: member.id, friend_id: member.id }, { "Accept" => "application/json" }
      end

      it "success" do
        expect(json["response_status"]).to eq("OK")
      end

      it "has key as friend, following, follower, block" do
        expect(json.has_key?("friend")).to be true
        expect(json.has_key?("following")).to be true
        expect(json.has_key?("follower")).to be true
        expect(json.has_key?("list_block")).to be true
      end

    end


    context "friend" do
      before do
        get "/friend/collection_profile.json", { member_id: member.id, friend_id: friend.id }, { "Accept" => "application/json" }
      end

      it "success" do
        expect(json["response_status"]).to eq("OK")
      end

      it "has key as friend, following, follower, block" do
        expect(json.has_key?("friend")).to be true
        expect(json.has_key?("following")).to be true
        expect(json.has_key?("follower")).to be true
      end
    end
  end

  describe "GET /friend/find_via_facebook" do

    let!(:friend_facebook_1) { create(:member, email: "fb_1@gmail.com", fullname: "fb1", fb_id: "1234") }
    let!(:friend_facebook_2) { create(:member, email: "fb_2@gmail.com", fullname: "fb2", fb_id: "5678") }
    let!(:friend_facebook_3) { create(:member, email: "fb_3@gmail.com", fullname: "fb3", fb_id: "0123") }

    it "does something" do
      get '/friend/find_via_facebook.json', { member_id: member.id, list_fb_id: ["1234", "5678"] }, { "Accept" => "application/json" }

      expect(json["response_status"]).to eq("OK")

      expect(json["friend"].size).to eq(2)  
    end
    
  end

end