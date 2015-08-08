require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Story: #{pathname.dirname.basename}/#{pathname.basename}]\n\nUser reporting comments" do

    let!(:member) { create(:member, fullname: "Nuttapon", email: "nuttapon@gmail.com") }
    let!(:another_member) { create(:member, fullname: Faker::Name.name, email: Faker::Internet.email)}

    let!(:poll) { create(:faker_test_poll, member: member) }

    let!(:comment_from_member) { create(:comment, poll: poll, member: member, message: "test comment") }
    let!(:comment_from_another_member) { create(:comment, poll: poll, member: another_member, message: Faker::Lorem.sentence )}

    # using ListPoll class in Member module to fetch list of comments this user has reported
    let(:comments_reported_by_member) { Member::ListPoll.new(member).report_comments }
  
    context "A User report his own comment" do
        it "- user never report any comment (report count = 0)" do
            expect(comments_reported_by_member.size).to eq(0)
        end

        it "- user try reporting his own comment (should == false/nil)" do
            expect(ReportComment.new(member, comment_from_member, {message: "spam"}).reporting).to be_falsey
        end
    end

    context "A User reporting on another user's comment" do
        it "- user never report any comment (report count = 0)" do
            expect(comments_reported_by_member.size).to eq(0)
        end

        it "- user try reporting another user's comment (should == true/object), comment's report count == 1, user's comment report = 1" do
            expect(ReportComment.new(member, comment_from_another_member, {message: "spam"}).reporting).to be_truthy
            expect(comment_from_another_member.report_count).to eq(1)
            expect(comments_reported_by_member.size).to eq(1)
        end
    end

end

