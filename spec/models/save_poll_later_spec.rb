require 'rails_helper'

RSpec.describe SavePollLater, :type => :model do
  it { should belong_to(:member) }
  it { should belong_to(:savable) }


  let!(:member) { create(:member) }
  let!(:questionnaire) { create(:poll_series, member: member) }
  let!(:first_poll) { create(:poll, poll_series: questionnaire, member: member) }
  let!(:second_poll) { create(:poll, poll_series: questionnaire, member:member) }

  describe ".get_only_questionnaire_id" do
    let!(:saved_poll) { create(:save_poll_later, member: member, savable: questionnaire) }

    it "return array ids of poll series" do
      expect(SavePoll.new({ member_id: member.id}).get_list_questionnaire_id).to eq([questionnaire.id])
    end

  end

  describe ".get_only_poll_id" do
    let!(:saved_poll) { create(:save_poll_later, member: member, savable: first_poll) }

    it "return array ids of poll" do
      expect(SavePoll.new({ member_id: member.id}).get_list_poll_id).to eq([first_poll.id])  
    end

  end
end
