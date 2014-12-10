require 'rails_helper'

RSpec.describe "Poll" do

  let!(:member) { create(:member, fullname: "Nutty", email: "nutty@gmail.com") }

  # before do
  #   3.times do
  #     Poll.create_poll(FactoryGirl.attributes_for(:create_poll).merge(member_id: ex_member.id), ex_member)
  #   end

  #   get "/poll/#{ex_member.id}/overall_timeline", { api_version: 6 }, { "Accept" => "application/json" }
  # end

  # it "sends a list of polls feed" do
  #   expect(response).to be_success
  #   expect(json["response_status"]).to eq("OK")
  # end

  # it "returns three poll in poll feed " do
  #   expect(json["timeline_polls"].size).to eq(3)
  # end

  # it "returns 20 poll per request" do
  #   40.times do
  #     Poll.create_poll(FactoryGirl.attributes_for(:create_poll).merge(member_id: ex_member.id), ex_member)
  #   end

  #   get "/poll/#{ex_member.id}/overall_timeline", { api_version: 6 }, { "Accept" => "application/json" }

  #   expect(json["timeline_polls"].size).to eq(20)
  # ends

  describe "POST /poll/:id/un_see" do

    let!(:poll) { create(:poll, member_id: member.id) }

    it "creates unsee" do

      post "/poll/#{poll.id}/un_see", { member_id: member.id }, { "Accept" => "application/json" }

      expect(response.status).to eq(201)

      expect(json["response_status"]).to eq("OK")

      expect(UnSeePoll.count).to eq(1)
    end

    it "cannot unsee poll" do
      UnSeePoll.create!(member_id: member.id, unseeable: poll)

      post "/poll/#{poll.id}/un_see", { member_id: member.id }, { "Accept" => "application/json" }
      expect(response.status).to eq(422)
      expect(json["response_status"]).to eq("ERROR")
      expect(json["response_message"]).to eq("You already save to unsee poll")
      expect(UnSeePoll.count).to eq(1)
    end
  end

  describe "POST /poll/:id/vote" do
    
  end

  # describe "POST /poll/:id/save_latar" do
  #   let!(:poll) { create(:poll, member_id: member.id) }

  #   it "creates save for later" do
  #     post "/poll/#{poll.id}/save_latar", { member_id: member.id }, { "Accept" => "application/json" }

  #     expect(response).to be_success

  #     expect(json["response_status"]).to eq("OK")

  #     expect(SaveForLater.count).to eq(1)
  #   end
  # end

end