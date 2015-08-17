require 'rails_helper'

RSpec.describe "Comment API" do
  let!(:member) { create(:member) }
  let!(:another_member) { create(:member, fullname: Faker::Name.name, email: Faker::Internet.email)}
  let!(:poll) { create(:poll, member: member, allow_comment: true) }
  let!(:poll_not_allows_comment) { create(:poll, member: member, allow_comment: false) }

  before do
    post "/poll/#{poll.id}/comments.json", { member_id: member.id, message: "test title" }, { "Accept" => "application/json" }
  end

  describe "POST /poll/:id/comments" do

    it "can comment" do
      expect(response.status).to eq(201)
      expect(json["response_status"]).to eq("OK")
    end

    it "have 1 comment_count to poll" do
      expect(poll.reload.comment_count).to eq(1)
    end

    context "when commenting on a poll that's not allowing comment" do
      before do
        post "/poll/#{poll_not_allows_comment.id}/comments.json", { member_id: member.id, message: "couldn't post"}, {"Accept" => "application/json"}
      end

      it "return 422" do
        # poll.update!(allow_comment: false)
        # post "/poll/#{poll.id}/comments.json", { member_id: member.id, message: "test comment" }, { "Accept" => "application/json" }

        expect(json["response_status"]).to eq("ERROR")
        expect(json["response_message"]).to eq("Poll had already disabled comment.")
        expect(response.status).to eq(422)
      end

      it "comment count still zero" do
        expect(poll_not_allows_comment.reload.comment_count).to eq(0)
      end
    end
  end

  describe "DELETE /poll/:id/comments/:comment_id/delete" do
    let!(:comment) { create(:comment, poll: poll, member: member, message: "test comment") }

    before do
      # poll.increment!(:comment_count, 10)
      delete "/poll/#{poll.id}/comments/#{comment.id}/delete.json", { member_id: member.id } ,{ "Accept" => "application/json" }
    end

    it "can deleted" do
      expect(response.status).to eq(201)
    end

    it "decrement comment count" do
      # expect(poll.reload.comment_count).to eq(9)
      expect(poll.reload.comment_count).to eq(0)
    end
  end


  describe "GET /poll/:id/comments.json" do
    before do
      get "/poll/#{poll.id}/comments.json", { member_id: member.id }, { "Accept" => "application/json" }
    end

    it "return successfully" do
      expect(response.status).to eq(200)
    end

    it "has 1 comment on this poll" do
      create(:comment, poll: poll, member: member, message: "Test Comment")
      expect(json["comments"].count).to eq(1)
    end

  end

  describe "POST /comment/:id/report" do
    let!(:comment_one) { create(:comment, poll: poll, member: member, message: "Don't like this") }
    let!(:comment_two) { create(:comment, poll: poll, member: member, message: "Don't like that") }

    before do
      post "/comment/#{comment_one.id}/report.json", { member_id: another_member.id, message: "This is spam" }, { "Accept" => "application/json" }
    end

    it "reported" do
      expect(response.status).to eq(201)
    end

    it "has report count 1 of comment one" do
      expect(comment_one.reload.report_count).to eq(1)
      expect(Member::ListPoll.new(another_member).report_comments.size).to eq(1)
    end
  end
end
