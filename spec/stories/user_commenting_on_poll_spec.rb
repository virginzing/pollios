require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Story: #{pathname.dirname.basename}/#{pathname.basename}]\n\n User commenting on a poll" do

    let!(:member) { create(:member, fullname: "Nuttapon", email: "nuttapon@gmail.com") }
    let!(:another_member) { create(:member, fullname: Faker::Name.name, email: Faker::Internet.email)}

    # let!(:poll2) { create(:poll, member: member) }

    # let!(:comment_from_member) { create(:comment, poll: poll, member: member, message: "test comment") }
    # let!(:comment_from_another_member) { create(:comment, poll: poll, member: another_member, message: Faker::Lorem.sentence )}

    # # using ListPoll class in Member module to fetch list of comments this user has reported
    # let(:comments_reported_by_member) { Member::ListPoll.new(member).report_comments }

    context "A user commenting on a poll not allowing comment" do
        let(:poll) { create(:poll, :not_allow_comment, member: member) }
        it "- a poll should not allow commenting (poll.allow_comment == false)" do
            expect(poll.allow_comment).to be false
        end

        it "- a user commenting on this poll, should not be allow" do
            poll_comment = PollCommenting.new(poll, member, Faker::Lorem.sentence)
            expect(poll_comment.commenting).to be false
        end
    end

    context "A user commenting on a poll allowing comment" do
        let(:poll) { create(:poll, member: member) }

        it "- a poll should allow commenting (poll.allow_comment == true)" do
            expect(poll.allow_comment).to be true
        end

        it "- a user commenting on this poll, can do, and increase comment count" do
            poll_comment = PollCommenting.new(poll, member, Faker::Lorem.sentence)
            expect(poll_comment.commenting).to be true
            expect(poll.comment_count).to eq(1)
        end
    end

    # TODO: This will be tested with AllowComment service class
    #
    # context "A user disable comment on his poll, another user attempt to comment" do
    #     let(:poll) { create(:poll, member: member) }

    #     it "- should be able to disable comment on his own poll" do
    #         poll_comment = PollComment.new(poll, member, Faker::Lorem.sentence)
    #         expect(poll_comment.disable_comment).to be true
    #         expect(poll_comment.commenting).to be false
    #         expect(poll.comment_count).to eq(0)
    #     end
    # end
end