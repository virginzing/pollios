require 'rails_helper'

RSpec.describe "Save Poll" do

  before do
    @init = SavePoll.new( {member_id: member.id} )
  end

  let!(:member) { create(:member) }
  let!(:poll) { create(:poll, member: member) }
  let!(:questionnaire) { create(:poll_series, member: member) }

  it "return member_id" do
    expect(@init.member_id).to eq(member.id)
  end

  describe ".get_list_poll_id" do

    before do
      create(:save_poll_later, member: member, savable: poll)
    end

    it "return 1 poll in save poll later" do
      expect(@init.get_list_poll_id.size).to eq(1)
      expect(@init.get_list_poll_id).to eq([poll.id])
    end

  end

  describe ".get_list_questionnaire_id" do
    before do
      create(:save_poll_later, member: member, savable: questionnaire)
    end

    it "return 1 questionnaire in save poll later" do
      expect(@init.get_list_questionnaire_id.size).to eq(1)
      expect(@init.get_list_questionnaire_id).to eq([questionnaire.id])
    end
  end

end