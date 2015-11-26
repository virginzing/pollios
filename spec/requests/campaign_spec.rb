require 'rails_helper'

RSpec.describe "Campaign" do
  let!(:member) { create(:member, fullname: "Nutty", point: 0) }
  let!(:company) { create(:company, name: "Pollios", member: member) }
  let!(:campaign) { create(:campaign, name: "แจก 5 Point for public poll", company: company, redeem_myself: true, reward_info: { point: 5 }, system_campaign: true,
    rewards_attributes: [{ title: "5 public poll", detail: "free  public poll", reward_expire: Time.zone.now + 1.year }] ) }


  describe "GET /member/list_reward.json" do
    context "when user have not reward" do
      before do
        get "/member/list_reward.json", { member_id: member.id }, { "Accept" => "application/json" }
      end

      it "success" do
        expect(json["response_status"]).to eq("OK")
      end

      it "have 0 reward" do
        expect(MemberReward.with_reward_status(:receive).count).to eq(0)
        expect(json["list_reward"].count).to eq(0)
      end
    end


    context "when user have any reward" do
      before do
        create(:campaign_member, member: member, campaign: campaign, reward_status: :receive, serial_code: campaign.generate_serial_code, ref_no: campaign.generate_ref_no)
        get "/member/list_reward.json", { member_id: member.id }, { "Accept" => "application/json" }
      end

      it "success" do
        expect(json["response_status"]).to eq("OK")
      end

      it "have 1 reward" do
        expect(MemberReward.with_reward_status(:receive).count).to eq(1)
        expect(json["list_reward"].count).to eq(1)
      end
    end
  end


  describe "POST /campaign/claim_reward" do
    context "user have reward" do
      let!(:campaign_member) { create(:campaign_member, member: member, campaign: campaign, reward_status: :receive, serial_code: campaign.generate_serial_code, ref_no: campaign.generate_ref_no) }

      before do
        post "/campaign/claim_reward.json", { member_id: member.id, reward_id: campaign_member.id, ref_no: campaign_member.ref_no}
      end

      it "success" do
        expect(json["response_status"]).to eq("OK")
      end

      it "point increment 5" do
        expect(member.reload.point).to eq(5)
      end

      it "cannot claim to same reward" do
        post "/campaign/claim_reward.json", { member_id: member.id, reward_id: campaign_member.id, ref_no: campaign_member.ref_no}
        expect(json["response_status"]).to eq("ERROR")
      end
    end
  end

end
