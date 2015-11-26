# == Schema Information
#
# Table name: campaigns
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  photo_campaign  :string(255)
#  used            :integer          default(0)
#  limit           :integer          default(0)
#  member_id       :integer
#  created_at      :datetime
#  updated_at      :datetime
#  begin_sample    :integer          default(1)
#  end_sample      :integer
#  expire          :datetime
#  description     :text
#  how_to_redeem   :text
#  company_id      :integer
#  type_campaign   :integer
#  redeem_myself   :boolean          default(FALSE)
#  reward_info     :hstore
#  reward_expire   :datetime
#  system_campaign :boolean          default(FALSE)
#  announce_on     :datetime
#

require 'rails_helper'

RSpec.describe Campaign, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:limit) }

  it { should have_many(:polls) }
  it { should have_many(:poll_series) }
  it { should have_many(:members) }
  it { should belong_to(:member) }
  it { should belong_to(:company) }
  it { should have_many(:rewards) }


  describe '#prediction' do
    let!(:member_system) { create(:member_system) }
    let!(:member) { create(:member) }
    let!(:company) { create(:company_admin) }
    let!(:rewards) { create_list(:reward, 1) }
    let!(:campaign) do 
      create(:campaign, member: member_system, company: company, name: 'แจก 1 public poll free', 
                        expire: Time.now + 100.years, used: 0, reward_info: { point: 1 }, 
                        system_campaign: true, rewards: rewards)
    end


    let!(:poll) { create(:poll, member: member_system, title: 'test for campaign', campaign: campaign) }


    it 'can receive reward' do
      campaign.prediction(member.id, poll.id)
      expect(MemberReward.with_reward_status(:receive).where(member_id: member.id, campaign_id: campaign.id).size).to eq(1)
    end

    it "don't receive reward when expire" do
      campaign.update(expire: 1.days.ago)
      expect { campaign.reload.prediction(member.id, poll.id) }.to raise_error('This campaign was expired.')
    end

    it "don't receive reward when over limit" do
      campaign.update(used: 100, limit: 100)
      expect { campaign.reload.prediction(member.id, poll.id) }.to raise_error('This campaign was limit.')
    end

    it "don't receive reward when you've received this reward already before" do
      create(:campaign_member, member: member, campaign: campaign, reward_status: :receive, poll: poll)
      expect { campaign.reload.prediction(member.id, poll.id) }.to raise_error('You used to get this reward of poll.')
    end
  end
end
