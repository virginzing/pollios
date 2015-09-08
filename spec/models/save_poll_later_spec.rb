# == Schema Information
#
# Table name: save_poll_laters
#
#  id           :integer          not null, primary key
#  member_id    :integer
#  savable_id   :integer
#  savable_type :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

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

    it "return array ids of poll series/questionnaire" do
      expect(Member::PollList.new(member).saved_questionnaire_ids).to eq([questionnaire.id])
    end

  end

  describe ".get_only_poll_id" do
    let!(:saved_poll) { create(:save_poll_later, member: member, savable: first_poll) }

    it "return array ids of poll" do
      expect(Member::PollList.new(member).saved_poll_ids).to eq([first_poll.id])  
    end

  end

  describe "#delete_save_later" do
    context 'only poll' do
      let!(:saved_poll) { create(:save_poll_later, member: member, savable: first_poll) }

      it "remove save later" do
        expect(SavePollLater.delete_save_later(member.id, first_poll)).to eq(true)
      end      
    end

    context 'only questionnaire' do
      let!(:saved_poll) { create(:save_poll_later, member: member, savable: questionnaire) }

      it "remove save later" do
        expect(SavePollLater.delete_save_later(member.id, questionnaire)).to eq(true)
      end
    end

  end
end
