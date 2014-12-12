require 'rails_helper'

describe "GET /friend/watched", type: :api do

  let!(:member) { create(:member, fullname: "Nutkub", email: "nutkub@gmail.com") }
  let!(:poll) { create(:poll, member: member) }

  before do
    create(:watched, poll: poll, member: member)
  end

  it "return my watched's created" do
    
    get 'friend/watched.json', { member_id: member.id, friend_id: member.id, api_version: 6  }, { "Accept" => "application/json" }
    expect(last_response.status).to eq(200)
    expect(json["response_status"]).to eq("OK")
    expect(json["timeline_polls"].size).to eq(1)
  end

end
