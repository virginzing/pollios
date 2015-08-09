require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\nPollCommenting" do
    let!(:member) { create(:member, fullname: "Nuttapon", email: "nuttapon@gmail.com") }
    let!(:another_member) { create(:member, fullname: Faker::Name.name, email: Faker::Internet.email)}

    # let!(:poll2) { create(:poll, member: member) }

    # let!(:comment_from_member) { create(:comment, poll: poll, member: member, message: "test comment") }
    # let!(:comment_from_another_member) { create(:comment, poll: poll, member: another_member, message: Faker::Lorem.sentence )}

    # # using ListPoll class in Member module to fetch list of comments this user has reported
    # let(:comments_reported_by_member) { Member::ListPoll.new(member).report_comments }

    context "A user commenting on a poll not allowing comment" do
        let(:poll) { create(:poll, :not_allow_comment, member: member) }
        it "- a poll does not allow commenting" do
            expect(poll.allow_comment).to be false
        end

        it "- a user commenting on this poll, should not be allow" do
            poll_comment = PollCommenting.new(poll, member, Faker::Lorem.sentence)
            expect(poll_comment.commenting).to be false
        end
    end

    context "A user commenting on a poll allowing comment" do
        let(:poll) { create(:poll, member: member) }

        it "- a poll allows commenting" do
            expect(poll.allow_comment).to be true
        end

        it "- a user commenting on this poll, can do, and increase comment count" do
            poll_comment = PollCommenting.new(poll, member, Faker::Lorem.sentence)
            expect(poll_comment.commenting).to be true
            expect(poll.comment_count).to eq(1)
        end
    end
end