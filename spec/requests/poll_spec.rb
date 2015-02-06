require 'rails_helper'

RSpec.describe "Poll" do

  let!(:member) { create(:member, fullname: "Nutty", email: "nutty@gmail.com") }
  let!(:friend) { create(:member, fullname: "Ning", email: "ning@gmail.com") }
  let!(:second_member) { create(:member, fullname: "Nutty 2", email: "nutty_2@gmail.com") }
  let!(:poll) { create(:poll, member: member) }
  let!(:choice_one) { create(:choice, poll: poll, answer: "1", vote: 0) }
  let!(:choice_two) { create(:choice, poll: poll, answer: "2", vote: 0) }

  describe "POST /poll/create" do
    context "friend & following" do
      
      before do
        post "/poll/create.json", { member_id: member.id, title: "test title", choices: ["1", "2", "3"], type_poll: "binary", creator_must_vote: false }, { "Accept" => "application/json"}
        @poll_last = Poll.unscoped.last
      end

      it "created" do
        expect(response.status).to eq(201)
      end

      it "have value default" do
        expect(@poll_last.qrcode_key.present?).to be true
        expect(@poll_last.member_id).to eq(member.id)
      end

      it "add to member poll" do
        poll_member = PollMember.find_by(member: member, poll: @poll_last, share_poll_of_id: 0, public: false, series: false, expire_date: @poll_last.expire_date, in_group: false, poll_series_id: 0)
        expect(poll_member.present?).to be true
      end

    end
  end

  describe "POST /poll/:id/un_see" do
    it "creates unsee" do

      post "/poll/#{poll.id}/un_see", { member_id: member.id }, { "Accept" => "application/json" }

      expect(response.status).to eq(201)

      expect(json["response_status"]).to eq("OK")

      expect(UnSeePoll.count).to eq(1)
    end

    it "cannot unsee poll" do
      UnSeePoll.create!(member_id: member.id, unseeable: poll)

      post "/poll/#{poll.id}/un_see", { member_id: member.id }, { "Accept" => "application/json" }
      expect(response.status).to eq(422)
      expect(json["response_status"]).to eq("ERROR")
      expect(json["response_message"]).to eq("You already save to unsee poll")
      expect(UnSeePoll.count).to eq(1)
    end
  end

  describe "POST /poll/:id/vote" do
    it "can vote" do
      post "/poll/#{poll.id}/vote", { member_id: member.id, choice_id: choice_one.id }, { "Accept" => "application/json" }

      expect(response.status).to eq(200)
      expect(json["response_status"]).to eq("OK")
      expect(json.has_key?("information")).to be true
      expect(json.has_key?("scroll")).to be true
      expect(json.has_key?("vote_max")).to be true
      poll.reload
      choice_one.reload
      expect(poll.vote_all).to eq(1)
      expect(choice_one.vote).to eq(1)
    end

    it "can not vote when not found poll" do
      post "/poll/1/vote", { member_id: member.id, choice_id: choice_one.id }, { "Accept" => "application/json" }

      expect(json["response_status"]).to eq("ERROR")
      expect(json["response_message"]).to eq("Poll not found")
    end

    it "can not vote when not found choice" do
      post "/poll/#{poll.id}/vote", { member_id: member.id, choice_id: 1 }, { "Accept" => "application/json" }

      expect(json["response_status"]).to eq("ERROR")
      expect(json["response_message"]).to eq("Choice not found")
    end
  end

  describe "POST /poll/:id/save_latar" do

    it "save poll later" do

      post "/poll/#{poll.id}/save_later.json", { member_id: member.id }, { "Accept" => "application/json" }

      expect(response.status).to eq(201)

      expect(json["response_status"]).to eq("OK")

      expect(SavePollLater.count).to eq(1)
    end
  end

  describe "POST /poll/:id/un_save_later" do

    it "un save poll later" do
      create(:save_poll_later, member: member, savable: poll)

      expect(SavePollLater.count).to eq(1)

      post "/poll/#{poll.id}/un_save_later.json", { member_id: member.id }, { "Accept" => "application/json" }

      expect(json["response_status"]).to eq("OK")

      expect(SavePollLater.count).to eq(0)
    end
  end

  describe "POST /poll/:id/bookmark" do
    it "can bookmark" do

      post "/poll/#{poll.id}/bookmark.json", { member_id: member.id }, { "Accept" => "application/json" }

      expect(response.status).to eq(201)
      
      expect(json["response_status"]).to eq("OK")

      expect(Bookmark.count).to eq(1)
    end
  end

  describe "POST /poll/:id/un_bookmark" do
    it "unbookmark" do
      create(:bookmark, member: member, bookmarkable: poll)

      expect(Bookmark.count).to eq(1)

      post "/poll/#{poll.id}/un_bookmark.json",  { member_id: member.id }, { "Accept" => "application/json" }

      expect(json["response_status"]).to eq("OK")

      expect(Bookmark.count).to eq(0)
    end
  end

  describe "GET /poll/:id/member_voted" do

    before do
      create(:history_vote, member: member, poll: poll, choice: choice_one, show_result: true)
      create(:history_vote, member: friend, poll: poll, choice: choice_one, show_result: false)
      create(:history_vote, member: second_member, poll: poll, choice: choice_one, show_result: true)
    end

    it "show detail of member as un_anonymous" do
      get "/poll/#{poll.id}/member_voted.json", { member_id: member.id, choice_id: choice_one.id }, { "Accept" => "application/json" }

      expect(json["response_status"]).to eq("OK")

      expect(json["member_voted_show_result"].size).to eq(2)
    end

    it "count to show result equal 2" do
      history_vote = HistoryVote.where(poll: poll, choice: choice_one)

      expect(history_vote.to_a.count).to eq(3)

      expect(history_vote.select{|e| e if e.show_result }.count).to eq(2)
    end
  end


  describe "POST /poll/:id/close_comment" do
    before do
      @poll_last = create(:poll, title: "eiei", member: member, allow_comment: true)
      post "/poll/#{@poll_last.id}/close_comment.json", { member_id: member.id }, { "Accept" => "application/json" }
    end

    it "success" do
      expect(response.status).to eq(201)
    end

    it "close comment of poll" do
      expect(@poll_last.reload.allow_comment).to be false
    end
  end

  describe "POST /poll/:id/open_comment" do
    before do
      @poll_last = create(:poll, title: "eiei", member: member, allow_comment: false)
      post "/poll/#{@poll_last.id}/open_comment.json", { member_id: member.id }, { "Accept" => "application/json" }
    end

    it "success" do
      expect(response.status).to eq(201)
    end

    it "close comment of poll" do
      expect(@poll_last.reload.allow_comment).to be true
    end
  end

end