require 'rails_helper'

describe "GET /hashtag", type: :api do
  let!(:member) { create(:member) }
  let!(:poll) { create(:poll, member: member) }
  let!(:tag) { create(:tag, name: "Nisekoi") }

  before do
    create(:tagging, tag: tag, poll: poll)
    create(:poll_member, member: member, poll: poll, share_poll_of_id: 0, public: false, series: false, in_group: false, poll_series_id: 0)
  end

  it "return list of hashtag" do
    get "/hashtag.json", { member_id: member.id, name: "Nisekoi", api_version: 6 }, { "Accept" => "application/json" }

    expect(last_response.status).to eq(200)
    expect(json["response_status"]).to eq("OK")
    expect(json["timeline_polls"].size).to eq(1)
  end

end