require 'rails_helper'

RSpec.describe "Friend" do

  let!(:member) { create(:member, fullname: "Nutkub", email: "nutkub@gmail.com") }
  let!(:friend) { create(:member, fullname: "Ning", email: "ning@gmail.com") }

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

end