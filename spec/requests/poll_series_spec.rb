require 'rails_helper'

RSpec.describe "PollSeries" do

  let!(:member) { create(:member, fullname: "Nutty", email: "nutty@gmail.com") }

  describe "POST /questionnaire/:id/un_see" do

    let!(:questionnaires) { create(:poll_series) }

    it "can unsee" do

      post "/questionnaire/#{questionnaires.id}/un_see", { member_id: member.id }, { "Accept" => "application/json" }

      expect(response.status).to eq(201)

      expect(json["response_status"]).to eq("OK")

      expect(UnSeePoll.count).to eq(1)
    end
  end


end