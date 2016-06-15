require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\nReport::Comment" do
    let!(:member) { create(:member, fullname: "Nuttapon", email: "nuttapon@gmail.com") }
    let!(:another_member) { create(:member, fullname: Faker::Name.name, email: Faker::Internet.email)}

    let!(:poll) { create(:poll, member: member) }

    let!(:comment_from_member) { create(:comment, poll: poll, member: member, message: "test comment") }
    let!(:comment_from_another_member) { create(:comment, poll: poll, member: another_member, message: Faker::Lorem.sentence )}

    # using ListPoll class in Member module to fetch list of comments this user has reported
    let(:comments_reported_by_member) { Member::PollList.new(member).report_comments }

    context "A User report his own comment" do
        it "- (pre-check) user never report any comment" do
            expect(comments_reported_by_member.size).to eq(0)
        end

        it "- user try reporting his own comment. cannot do." do
            expect(Report::Comment.new(member, comment_from_member, {message: "spam"}).reporting).to be_falsey
        end
    end

    context "A User reporting on another user's comment" do
        it "- (pre-check) user never report any comment" do
            expect(comments_reported_by_member.size).to eq(0)
        end

        it "- user can report another user's comment. also incrase comment's report count & user's comment report" do
            expect(Report::Comment.new(member, comment_from_another_member, {message: "spam"}).reporting).to be_truthy
            expect(comment_from_another_member.report_count).to eq(1)
            expect(comments_reported_by_member.size).to eq(1)
        end
    end

    context "A User with high reporting power reporting user's comment" do
        let(:member_with_power_3) { create(:member, fullname: Faker::Name.name, email: Faker::Internet.email, report_power: 3)}

        it "has report count 3 when reported by member with report power 3" do
            Report::Comment.new(member_with_power_3, comment_from_member, { message: "spam" }).reporting
            expect(comment_from_member.report_count).to eq(3)
        end
    end
end
