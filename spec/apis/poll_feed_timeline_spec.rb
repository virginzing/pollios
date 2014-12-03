require 'rails_helper'

describe "GET /overall_timeline", type: :api do
  let!(:member) { create(:member) }

  before do
    3.times do
      Poll.create_poll(FactoryGirl.attributes_for(:create_poll).merge(member_id: member.id), member)
    end
  end

  it "sends a list of poll feed" do
    # 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(member.get_token("facebook"))
    get "/poll/#{member.id}/overall_timeline.json", { api_version: 6 }
    # puts last_response.body
    expect(last_response.status).to eq(200)

    expect(json["response_status"]).to eq("OK")
    expect(json["timeline_polls"].size).to eq(3)
  end

  # it "should return a Access Deny" do
  #   get "/poll/#{member.id}/overall_timeline.json", { api_version: 6 }
  #   expect(last_response.status).to eq(401)
  # end


end