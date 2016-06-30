# require 'rails_helper'

# pathname = Pathname.new(__FILE__)
# RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\nReport::Comment" do

#   context "A User report his own comment" do
#     before(:context) do
#       @member = create(:member)
#       @poll_params = attributes_for(:poll)
#       @poll = Member::PollAction.new(@member, @poll).create(@poll_params)

#       @comment_from_member = create(:comment, poll: @poll, member: @member, message: "test comment")
#       @comments_reported_by_member = Member::PollList.new(@member).report_comments
#     end

#     it "- (pre-check) user never report any comment" do
#       expect(@comments_reported_by_member.size).to eq(0)
#     end

#     it "- user try reporting his own comment. cannot do." do
#       expect(Report::Comment.new(@member, @comment_from_member, {message: "spam"}).reporting).to be_falsey
#     end
#   end

#   context "A User reporting on another user's comment" do
#     before(:context) do
#       @member_1 = create(:member, point: 1)
#       @member_2 = create(:member)

#       @poll_params = attributes_for(:poll, :with_public)
#       @poll = Member::PollAction.new(@member_1, @poll).create(@poll_params)
      
#       @choice = @poll.choices.sample
#       Member::PollAction.new(@member_2, @poll).vote(choice_id: @choice.id)

#       @member_2_comment_params = attributes_for(:comment)
#       @member_2_comment = Member::PollAction.new(@member_2, @poll).comment(@member_2_comment_params)
#     end

#     it "- (pre-check) user never report any comment" do
#       expect(Member::PollList.new(@member_1).report_comments.size).to eq(0)
#     end

#     it "- user can report another user's comment. also incrase comment's report count & user's comment report" do
#       expect(Report::Comment.new(@member_1, @member_2_comment, {message: "spam"}).reporting).to be_truthy
#       expect(@member_2_comment.report_count).to eq(1)
#       expect(Member::PollList.new(@member_1).report_comments.size).to eq(1)
#     end
#   end

#   context "A User with high reporting power reporting user's comment" do
#     before(:context) do
#       @member = create(:member)
#       @member_with_power_3 = create(:member, report_power: 3)
#       @poll = create(:poll, member: @member)
#       @comment_from_member = create(:comment, poll: @poll, member: @member, message: "test comment")
#     end

#     it "has report count 3 when reported by member with report power 3" do
#       Report::Comment.new(@member_with_power_3, @comment_from_member, { message: "spam" }).reporting
#       expect(@comment_from_member.report_count).to eq(3)
#     end
#   end
# end
