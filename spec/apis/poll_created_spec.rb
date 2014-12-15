require 'rails_helper'

describe "GET /friend/polls", type: :api do

  let!(:member) { create(:member, fullname: "Nutkub", email: "nutkub@gmail.com") }
  let!(:friend) { create(:member, fullname: "Ning", email: "ning@gmail.com") }

  before do
    3.times do
      Poll.create_poll(FactoryGirl.attributes_for(:create_poll).merge(member_id: member.id), member)
    end
    2.times do
      Poll.create_poll(FactoryGirl.attributes_for(:create_poll).merge(member_id: friend.id), friend)
    end
  end

  it "return my poll's created" do
    get 'friend/polls.json', { member_id: member.id, friend_id: member.id, api_version: 6  }, { "Accept" => "application/json" }
    expect(last_response.status).to eq(200)
    expect(json["response_status"]).to eq("OK")
    expect(json["timeline_polls"].size).to eq(3)
  end

  context 'when access to friend created poll' do
    before do
      Friend.add_friend( {member_id: member.id, friend_id: friend.id})
      Friend.accept_or_deny_freind({member_id: friend.id, friend_id: member.id}, true)
    end

    it "retrun my friend's created" do
      get 'friend/polls.json', { member_id: member.id, friend_id: friend.id, api_version: 6}, { "Accept" => "application/json" }
      expect(last_response.status).to eq(200)
      expect(json["response_status"]).to eq("OK")
      expect(json["timeline_polls"].size).to eq(2)
    end
  end
end