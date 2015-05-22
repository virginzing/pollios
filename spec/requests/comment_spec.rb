require 'rails_helper'

RSpec.describe "Comment" do
  let!(:member) { create(:member) }
  let!(:poll) { create(:poll, member: member, allow_comment: true) }

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
      it "return 422" do
        poll.update!(allow_comment: false)
        post "/poll/#{poll.id}/comments.json", { member_id: member.id, message: "test comment" }, { "Accept" => "application/json" }

        expect(json["response_status"]).to eq("ERROR")
        expect(json["response_message"]).to eq("Poll had already disabled comment.")
        expect(response.status).to eq(422)
      end
    end

    describe "DELETE /poll/:id/comments/:comment_id/delete" do
      let!(:comment) { create(:comment, poll: poll, member: member, message: "test comment") }

      before do
        poll.increment!(:comment_count, 10)
        delete "/poll/#{poll.id}/comments/#{comment.id}/delete.json", { member_id: member.id } ,{ "Accept" => "application/json" }
      end

      it "can deleted" do
        expect(response.status).to eq(201)
      end

      it "decrement comment count" do
        expect(poll.reload.comment_count).to eq(9)
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
  end

  describe "POST /comment/:id/report" do
    let!(:comment_one) { create(:comment, poll: poll, member: member, message: "Don't like this") }
    let!(:comment_two) { create(:comment, poll: poll, member: member, message: "Don't like that") }

    before do
      post "/comment/#{comment_one.id}/report.json", { member_id: member.id, message: "This is spam" }, { "Accept" => "application/json" }
    end 

    it "reported" do
      expect(response.status).to eq(201)
    end

    it "has report count 1 of comment one" do
      expect(comment_one.reload.report_count).to eq(1)
      expect(Member::ListPoll.new(member).report_comments.size).to eq(1)
    end
  end





end