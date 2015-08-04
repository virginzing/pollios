require 'rails_helper'

RSpec.describe "Reward" do
  let!(:company) { create(:company, name: "Test Company") }

  let!(:campaign) { create(:campaign, name: "แจก 5 Point for public poll", company: company, redeem_myself: true, reward_info: { point: 5 }, system_campaign: true,
    rewards_attributes: [{ title: "5 public poll", detail: "free  public poll", reward_expire: Time.zone.now + 1.year }] ) }

  let!(:member) { create(:member, fullname: "Nuttapn") }

  let!(:reward) { create(:campaign_member, member: member, campaign: campaign, reward_status: :receive, serial_code: campaign.generate_serial_code, ref_no: campaign.generate_ref_no) }


  describe "GET /reward/:id/detail" do
    before do
      get "/reward/#{reward.id}/detail", { member_id: member.id }, { "Accept" => "application/json" }
    end

    it "be success" do
      expect(json["response_status"]).to eq("OK")
    end

  end
end
