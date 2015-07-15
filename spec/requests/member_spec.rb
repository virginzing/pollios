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

    it "update fb_id when sync with facebook" do
      post "/member/update_profile.json", { member_id: member.id, fb_id: "12345678" }, { "Accept" => "application/json" }
      expect(member.reload.fb_id).to eq("12345678")
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
        expect(json["your_request"].size).to eq(1)
      end

      it "has one friend request when added" do
        get "/member/#{friend.id}/all_request.json", { }, { "Accept" => "application/json" }
        expect(json["friend_request"].size).to eq(1)
      end

      it "change status of user_one to invite" do
        expect(@user_one.reload.status).to eq("invite")
      end

      it "change status of user_two to invitee" do
        expect(@user_two.reload.status).to eq("invitee")
      end

    end

  end

  describe "POST /member/:id/invite_user_via_email" do
    list_email = []
    5.times { list_email << Faker::Internet.email }

    before do
      post "/member/#{member.id}/invite_user_via_email.json", { list_email: list_email }, { "Accept" => "application/json" }
    end

    it "success" do
      expect(response.status).to eq(200)
    end

    it "create invite" do
      expect(member.invites.size).to eq(5)
    end
  end


  describe "POST /member/:id/invite_fb_user" do
    list_fb_id = ["1111", "2222"]

    let!(:member_sync_one) { create(:member, fullname: "Nutty Sync Facebook", email: Faker::Internet.email, fb_id: "1111") }
    let!(:member_sync_two) { create(:member, fullname: "Mekumi Sync Facebook", email: Faker::Internet.email, fb_id: "2222") }

    it "is not yet invite friend" do
      find_friend_one = Friend.find_by(follower: member, followed: member_sync_one)
      find_friend_two = Friend.find_by(follower: member, followed: member_sync_two)

      expect(find_friend_one.nil?).to be true
      expect(find_friend_two.nil?).to be true
    end

    it "success" do
      post "/member/#{member.id}/invite_fb_user.json", { list_fb_id: list_fb_id }, { "Accept" => "application/json" }
      expect(response.status).to eq(200)
    end

    it "invite friend by fb_id" do
      post "/member/#{member.id}/invite_fb_user.json", { list_fb_id: list_fb_id }, { "Accept" => "application/json" }

      find_friend_one = Friend.find_by(follower: member, followed: member_sync_one)
      find_friend_two = Friend.find_by(follower: member, followed: member_sync_two)

      expect(find_friend_one.nil?).to be false
      expect(find_friend_two.nil?).to be false
    end
  end

  describe "GET /member/recommended_groups" do
    before do
      get "/member/recommended_groups.json", { member_id: member.id }, { "Accept" => "application/json" }
    end

    it "success" do
      expect(response.status).to eq(200)
    end
  end

  describe "GET /member/recommended_official" do

    let!(:member_one) { create(:member, email: "official_account_1@gpollios.com", member_type: :celebrity, show_recommend: true) }
    let!(:member_two) { create(:member, email: "official_account_2@gpollios.com", member_type: :celebrity, show_recommend: true) }

    before do
      get "/member/recommended_official.json", { member_id: member.id }, { "Accept" => "application/json" }
    end

    it "success" do
      expect(response.status).to eq(200)
    end

    it "has 2 recommended official accounts" do
      expect(json["recommendations_official"].size).to eq(2)
    end
  end

  describe "POST /member/:id/report" do
    let!(:member_one) { create(:member, email: "official_account_1@gpollios.com", member_type: :citizen) }
    let!(:member_two) { create(:member, email: "official_account_2@gpollios.com", member_type: :citizen) }

    let!(:friend) {  create(:friend, follower: member_one, followed: member_two, active: true, status: 1) }
    let!(:friend_2) { create(:friend, follower: member_two, followed: member_one, active: true, status: 1) }

    before do
      post "/member/#{member_two.id}/report.json", { member_id: member_one.id, message: "block", block: true }, { "Accept" => "application/json" }
    end

    it "success" do
      expect(response.status).to eq(201)
      expect(json["response_status"]).to eq("OK")
    end
  end

  describe "GET /member/notification_count" do
    let!(:member_with_notification) {  create(:member, fullname: 'Nuttapon', notification_count: 10, request_count: 5) }

    before do
      get "/member/notification_count.json", { member_id: member_with_notification.id }, { 'Accept' => 'application/json' }
    end

    it "be successfully" do
      expect(json['response_status']).to eq('OK')
    end

    it "has 10 notifications and 5 requests" do
      expect(json['notify_count']).to eq(10)
      expect(json['request_count']).to eq(5)
    end
  end

  describe "POST /member/activate" do
    let!(:company) { create(:company, member: member) }
    let!(:group) { create(:group, name: "Name Group") }
    let!(:company_group) { create(:company_group, group: group, member: member, main_group: true) }

    # let(:inivte_code) {  }
  end

  describe "POST /member/update_notification" do
    it "can update notification" do
      notification_sample = {
          "public"=>"0",
          "group"=>"0",
          "friend"=>"1",
          "watch_poll"=>"1",
          "request"=>"1",
          "join_group"=>"1"
      }
      post "/member/update_notification.json", { member_id: member.id, notification: notification_sample }, { "Accept" => "application/json" }

      member_notification = member.reload.notification

      expect(member_notification["join_group"]).to eq("1")
      expect(member_notification["group"]).to eq("0")

      expect(response.status).to eq(200)
    end
  end


end
