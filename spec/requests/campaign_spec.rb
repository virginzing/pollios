require 'rails_helper'

RSpec.describe "Campaign" do
  let(:member) { create(:member, fullname: "Nutty") }
  let(:company) { create(:company, name: "Pollios", member: member) }
  let(:campaign) { create(:campaign, name: "แจก 5 Point for public poll", company: company, member: member, redeem_myself: true, reward_info: { point: 10 } ) }


end