require 'rails_helper'

RSpec.describe "Comment" do
  let!(:member) { create(:member) }
  let!(:poll) { create(:poll, member: member) }

  describe "POST /poll/:id/comments" do
    before do
      post "/poll/#{poll.id}/comments.json", { member_id: member.id, message: "test title" }, { "Accept" => "application/json" }
    end

    it "can comment" do
      expect(response.status).to eq(201)
      expect(json["response_status"]).to eq("OK")
    end

    it "have 1 comment_count to poll" do
      expect(poll.reload.comment_count).to eq(1)
    end

    context "when disable comment" do
      it "return forbidden" do
        poll.update!(allow_comment: false)
        post "/poll/#{poll.id}/comments.json", { member_id: member.id, message: "test title" }, { "Accept" => "application/json" }

        expect(json["response_status"]).to eq("ERROR")
        expect(json["response_message"]).to eq("This poll disallow your comment")
        expect(response.status).to eq(403)
      end

    end

    describe "DELETE /poll/:id/comments/:comment_id/delete" do
      let!(:comment) { create(:comment, poll: poll, member: member, message: "test comment") }

      before do
        poll.increment!(:comment_count, 10)
        delete "/poll/#{poll.id}/comments/#{comment.id}/delete.json", { member_id: member.id } ,{ "Accept" => "application/json" }
      end

      it "can deleted" do
        expect(response.status).to eq(200)
      end

      it "decrement comment count" do
        expect(poll.reload.comment_count).to eq(9)
      end

    end 
  end



end