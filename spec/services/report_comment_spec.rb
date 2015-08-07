require 'rails_helper'

RSpec.describe "ReportComment Services (report_comment_spec.rb)" do
	let!(:member) { create(:member, fullname: "Nuttapon", email: "nuttapon@gmail.com") }
	let!(:another_member) { create(:member, fullname: Faker::Name.name, email: Faker::Internet.email)}

	# let!(:poll) { create(:poll, member: member, title: "test poll") }
	let!(:poll) { create(:faker_test_poll, member: member) }

	let!(:comment) { create(:comment, poll: poll, member: member, message: "test comment") }

	# using ListPoll class in Member module to create a new poll to be reported (test)
	let!(:report_comments) { Member::ListPoll.new(member).report_comments }

	it "user has empty of report comments" do
		expect(report_comments.size).to eq(0)
	end

	it "has report count 1 when this comment was reported by another member" do
		ReportComment.new(another_member, comment, { message: "spam" }).reporting
		expect(comment.report_count).to eq(1)
	end
end