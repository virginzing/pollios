require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\nReportComment" do
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

	let(:member_with_power_3) { create(:member, fullname: Faker::Name.name, email: Faker::Internet.email, report_power: 3)}

	it "has report count 3 when reported by member with report power 3" do
		ReportComment.new(member_with_power_3, comment, { message: "spam" }).reporting
		expect(comment.report_count).to eq(3)		
	end
end