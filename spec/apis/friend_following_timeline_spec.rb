require 'rails_helper'

describe "GET /poll/:member_id/friend_following_timeline", type: :api do
  let!(:member) { create(:member) }

  before do
    3.times do
      CreatePollService.new(member, FactoryGirl.attributes_for(:create_poll).merge(member_id: member.id)).create!
    end
  end

  it "return list of poll" do
    get "/poll/#{member.id}/friend_following_timeline.json", { api_version: 6 }

    expect(last_response.status).to eq(200)

    expect(json["response_status"]).to eq("OK")
    expect(json["timeline_polls"].size).to eq(3)
    expect(json["total_entries"]).to eq(3)
    expect(json["next_cursor"]).to eq(0)
  end


end
