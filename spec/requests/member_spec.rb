require 'rails_helper'

RSpec.describe "Member" do
  
  let!(:member) { create(:member, email: "faker_nut@gmail.com") }
  let!(:friend) { create(:member, fullname: "friend", email: "friend@gmail.com") }

  describe "POST /member/:id/device_token" do
  
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

  describe "GET /member/:id/all_request" do
    before do
      get "/member/#{member.id}/all_request.json", { }, { "Accept" => "application/json" }
    end

    it "be success" do
      expect(response.status).to eq(200)
    end

    it "must have key of friend request" do
      expect(json.has_key?("friend_request")).to be true
    end

    it "must have key of your request" do
      expect(json.has_key?("your_request")).to be true
    end

    context "have your request" do

      before do
        @user_one = create(:friend, follower: member, followed: friend, active: true, status: 0)
        @user_two = create(:friend, follower: friend, followed: member, active: true, status: 2)
      end

      it "has one your request when add friend" do
        get "/member/#{member.id}/all_request.json", { }, { "Accept" => "application/json" }
        expect(json["your_request"].count).to eq(1)
      end

      it "has one friend request when added" do
        get "/member/#{friend.id}/all_request.json", { }, { "Accept" => "application/json" }
        expect(json["friend_request"].count).to eq(1)
      end

      it "change status of user_one to invite" do
        expect(@user_one.reload.status).to eq("invite")
      end

      it "change status of user_two to invitee" do
        expect(@user_two.reload.status).to eq("invitee")
      end

    end

  end
end