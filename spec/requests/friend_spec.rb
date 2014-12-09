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
        get 'friend/save_poll_later.json', { member_id: member.id, friend_id: friend.id, api_version: 6 }, { "Accept" => "application/json" }
      
        expect(response).to be_success

        expect(json["response_status"]).to eq("OK")
      end

    end
  end
end