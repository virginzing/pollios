require 'rails_helper'

RSpec.describe "AuthenSentai" do
  let!(:member) { create(:member, fullname: "Nutty") }

  let!(:api_token_one) { create(:api_token, member: member, token: SecureRandom.hex(6), app_id: "com.pollios.polliosapp") }
  let!(:api_token_two) { create(:api_token, member: member, token: SecureRandom.hex(6), app_id: "com.pollios.polliosapp") }

  it "have 2 device" do
    expect(member.api_tokens.count).to eq(2)
  end

  it "logout all device" do
    delete "/signout_all_device.json", { member_id: member.id }, { "Accept" => "application/json" }

    expect(json["response_status"]).to eq("OK")
    expect(response.status).to eq(200)
    expect(member.api_tokens.count).to eq(0)
  end
end
