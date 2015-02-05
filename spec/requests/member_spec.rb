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



  describe "POST /member/update_profile" do

    let!(:member) { create(:member, email: "faker_nut@gmail.com") }
    let!(:friend) { create(:member, fullname: "friend", email: "friend@gmail.com") }

    context "update receive notify" do
      it "set receive notify to false" do
        post "/member/update_profile.json", { member_id: member.id, receive_notify: false }, { "Accept" => "application/json" }

        expect(json["response_status"]).to eq("OK")

        expect(member.reload.receive_notify).to be false
      end

      it "set receive notify to true" do
        post "/member/update_profile.json", { member_id: member.id, receive_notify: true }, { "Accept" => "application/json" }

        expect(json["response_status"]).to eq("OK")

        expect(member.reload.receive_notify).to be true
      end
    end


    it "update fullname & description" do
      post "/member/update_profile.json", { member_id: member.id, fullname: "Nuttapon", description: "I'm GreanNuT" }, { "Accept" => "application/json" }
      
      expect(json["response_status"]).to eq("OK")

      expect([member.reload.fullname, member.reload.description]).to eq(["Nuttapon", "I'm GreanNuT"])
    end

    it "set public_id" do
      post "/member/update_profile.json", { member_id: member.id, public_id: "07510509" }, { "Accept" => "application/json" }
      
      expect(json["response_status"]).to eq("OK")

      expect(member.reload.public_id).to eq("07510509")
    end

    it "set public_id via another api" do
      post "/member/#{member.id}/public_id.json", { public_id: "07510509" }, { "Accept" => "application/json" }

      expect(json["response_status"]).to eq("OK")

      expect(member.reload.public_id).to eq("07510509")
    end

    it "validate uniqueness of public_id" do
      post "/member/#{member.id}/public_id.json", { public_id: "07510509" }, { "Accept" => "application/json" }
      post "/member/#{friend.id}/public_id.json", { public_id: "07510509" }, { "Accept" => "application/json" }
      
      expect(json["response_status"]).to eq("ERROR")
      expect(json["response_message"]).to eq("Public ID has already been taken")
    end

  end
end