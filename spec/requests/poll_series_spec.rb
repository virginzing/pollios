require 'rails_helper'

RSpec.describe "PollSeries" do

  let!(:member) { create(:member, fullname: "Nutty", email: "nutty@gmail.com") }
  let!(:questionnaire) { create(:poll_series) }

  describe "POST /questionnaire/:id/un_see" do

    it "can unsee" do

      post "/questionnaire/#{questionnaire.id}/un_see", { member_id: member.id }, { "Accept" => "application/json" }

      expect(response.status).to eq(201)

      expect(json["response_status"]).to eq("OK")

      expect(NotInterestedPoll.count).to eq(1)
    end
  end


  describe "POST /questionnaire/:id/save_later" do
    it "can save later" do
      post "/questionnaire/#{questionnaire.id}/save_later", { member_id: member.id }, { "Accept" => "application/json" }
      expect(response.status).to eq(201)
      expect(json["response_status"]).to eq("OK")
      expect(SavePollLater.count).to eq(1)
    end
  end

  describe "POST /questionnaire/:id/un_save_later" do

    it "un save later" do
      create(:save_poll_later, member: member, savable: questionnaire)

      expect(SavePollLater.count).to eq(1)

      post "/questionnaire/#{questionnaire.id}/un_save_later", { member_id: member.id }, { "Accept" => "application/json" }

      expect(json["response_status"]).to eq("OK")

      expect(SavePollLater.count).to eq(0)
    end
  end


end
