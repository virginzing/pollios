require 'rails_helper'

describe "GET /poll/:member_id/overall_timeline", type: :api do
  let!(:member) { create(:member) }

  before do
    3.times do
      CreatePollService.new(member, FactoryGirl.attributes_for(:create_poll).merge(member_id: member.id)).create!
    end
  end

  it "return list of poll" do
    # 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(member.get_token("facebook"))
    get "/poll/#{member.id}/overall_timeline.json", { api_version: 6 }

    expect(last_response.status).to eq(200)

    expect(json["response_status"]).to eq("OK")
    expect(json["timeline_polls"].size).to eq(3)
    expect(json["total_entries"]).to eq(3)
    expect(json["next_cursor"]).to eq(0)
  end


end
