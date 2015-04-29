require 'rails_helper'

RSpec.describe Comment, :type => :model do
  it { should validate_presence_of(:message) }

  it { should belong_to(:member) }
  it { should belong_to(:poll) }


  describe "::report_comments" do
    let!(:member) { create(:member, fullname: "Nuttapon", email: "nuttapon@gmail.com") }
    let!(:poll) { create(:poll, member: member, title: "test poll") }
    let!(:comment) { create(:comment, poll: poll, member: member, message: "test comment") }

    let!(:report_comments) { Member::ListPoll.new(member).report_comments }

    it "has empty of report comments" do
      expect(report_comments.size).to eq(0)
    end

    it "has report count 1 when this comment was reported by someone" do
      ReportComment.new(member, comment, { message: "spam" }).reporting
      expect(comment.report_count).to eq(1)
    end


  end
end