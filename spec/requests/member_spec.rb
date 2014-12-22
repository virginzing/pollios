require 'rails_helper'

RSpec.describe "Member" do
  

  describe "POST /member/:id/device_token" do
    
    let!(:member) { create(:member) }
    let!(:device_token) { "11111111 11111111 11111111 11111111 11111111 11111111 11111111 11111111" }

    before do
      generate_certification
      post "/member/#{member.id}/device_token.json", { member_id: member.id, device_token: device_token }, { "Accept" => "application/json" }
    end

    it "update device token" do
      expect(json["response_status"]).to eq("OK")
    end

    it "have device token" do
      expect(Apn::Device.find_by_member_id_and_token(member.id, device_token).present?).to be true
    end
  end
end