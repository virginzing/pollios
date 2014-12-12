require 'rails_helper'

describe "GET /poll/:member_id/public_timeline", type: :api do
  let!(:member) { create(:member, member_type: :celebrity) }
  let!(:friend) { create(:member, email: "friend@gmail.com", fullname: "Friend" ) }

  before do
    3.times do
      Poll.create_poll(FactoryGirl.attributes_for(:create_poll_public).merge(member_id: member.id), member)
    end
  end

  it "return list of poll" do
    get "/poll/#{member.id}/public_timeline.json", { api_version: 6 }
    
    expect(last_response.status).to eq(200)

    expect(json["response_status"]).to eq("OK")
    expect(json["timeline_polls"].size).to eq(3)
    expect(json["total_entries"]).to eq(3)
    expect(json["next_cursor"]).to eq(0)
  end


end