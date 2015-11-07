# == Schema Information
#
# Table name: not_interested_polls
#
#  id             :integer          not null, primary key
#  member_id      :integer
#  unseeable_id   :integer
#  unseeable_type :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

require 'rails_helper'

RSpec.describe NotInterestedPoll, :type => :model do

  it { should belong_to(:member) }
  it { should belong_to(:unseeable) }

  let!(:member) { create(:member) }
  let!(:questionnaire) { create(:poll_series, member: member) }
  let!(:first_poll) { create(:poll, poll_series: questionnaire, member: member) }
  let!(:second_poll) { create(:poll, poll_series: questionnaire, member:member) }

  describe ".get_only_questionnaire_id" do
    let!(:unsee_questionnaire) { create(:not_interested_poll, member: member, unseeable: questionnaire) }

    it "return array ids of poll series" do
      expect(UnseePoll.new({ member_id: member.id}).get_list_questionnaire_id).to eq([questionnaire.id])
    end

  end

  describe ".get_only_poll_id" do
    let!(:unsee_poll) { create(:not_interested_poll, member: member, unseeable: first_poll) }

    it "return array ids of poll" do
      expect(UnseePoll.new({ member_id: member.id}).get_list_poll_id).to eq([first_poll.id])  
    end

  end

  describe ".delete_unsee" do
    context 'poll' do
      let!(:unsee_poll) { create(:not_interested_poll, member: member, unseeable: first_poll) }

      it "delete unsee" do
        expect(NotInterestedPoll.count).to eq(1)
        expect(UnseePoll.new({member_id: member.id, poll_id: first_poll.id}).delete_unsee_poll).to eq(true)
        expect(NotInterestedPoll.count).to eq(0)
      end
    end

    context 'questionnaire' do
      
    end
  
  end

end
