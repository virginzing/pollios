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
    let!(:poll) { create(:poll, member: member) }
    let!(:choice_one) { create(:choice, poll: poll, answer: "1", vote: 0) }
    let!(:choice_two) { create(:choice, poll: poll, answer: "2", vote: 0) }

    it "can vote" do
      post "/poll/#{poll.id}/vote", { member_id: member.id, choice_id: choice_one.id }, { "Accept" => "application/json" }

      expect(response.status).to eq(200)
      expect(json["response_status"]).to eq("OK")
      expect(json.has_key?("information")).to be true
      expect(json.has_key?("scroll")).to be true
      expect(json.has_key?("vote_max")).to be true
      poll.reload
      choice_one.reload
      expect(poll.vote_all).to eq(1)
      expect(choice_one.vote).to eq(1)
    end

    it "can not vote when not found poll" do
      post "/poll/1/vote", { member_id: member.id, choice_id: choice_one.id }, { "Accept" => "application/json" }

      expect(json["response_status"]).to eq("ERROR")
      expect(json["response_message"]).to eq("Poll not found")
    end

    it "can not vote when not found choice" do
      post "/poll/#{poll.id}/vote", { member_id: member.id, choice_id: 1 }, { "Accept" => "application/json" }

      expect(json["response_status"]).to eq("ERROR")
      expect(json["response_message"]).to eq("Choice not found")
    end
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