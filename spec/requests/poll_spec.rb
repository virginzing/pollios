require 'rails_helper'

RSpec.describe "Poll" do

  let!(:member) { create(:member, fullname: "Nutty", email: "nutty@gmail.com") }
  let!(:member_with_point) { create(:member, fullname: "NUT", email: "nuttyyy@gmail.com", point: 10) }

  let!(:friend) { create(:member, fullname: "Ning", email: "ning@gmail.com") }
  let!(:second_member) { create(:member, fullname: "Nutty 2", email: "nutty_2@gmail.com") }
  let!(:poll) { create(:poll, member: member, title: "eiei") }
  let!(:choice_one) { create(:choice, poll: poll, answer: "1", vote: 0) }
  let!(:choice_two) { create(:choice, poll: poll, answer: "2", vote: 0) }

  describe "POST /poll/create" do
    let!(:group) { create(:group, name: "My group 1", member: member) }
    let!(:group_member) { create(:group_member, group: group, member: member, is_master: true, active: true) }

    context "friend & following" do

      before do
        post "/poll/create.json", { member_id: member.id, title: "test title", choices: ["1", "2", "3"], type_poll: "freeform", creator_must_vote: true, allow_comment: true, is_public: false }, { "Accept" => "application/json"}
        @poll_last = Poll.unscoped.last
      end

      it "created" do
        expect(response.status).to eq(201)
      end

      it "must set qrcode every poll" do
        expect(@poll_last.qrcode_key.present?).to be_truthy
      end

      it "set campaign_id 0 when poll don't have campaign" do
        expect(@poll_last.campaign_id).to eq(0)
      end

      it "add to member poll" do
        expect(@poll_last.poll_members.present?).to be_truthy
      end

      it "would have key of json completely" do
        expect(json.has_key?("creator")).to be_truthy
        expect(json.has_key?("poll")).to be_truthy
        expect(json.has_key?("list_choices")).to be_truthy
        expect(json.has_key?("alert_message")).to be_falsey
      end

    end

    context "create poll to group" do
      before do
        post "poll/create.json", { member_id: member.id, title: "eiei", choices: ["A", "B"], type_poll: "freeform", creator_must_vote: true, allow_comment: true, group_id: group.id.to_s }, { "Accept" => "application/json"}
        @poll_last = Poll.unscoped.last
      end

      it "created poll to group" do
        expect(response.status).to eq(201)
      end

      it "add poll to group" do
        poll_group = PollGroup.find_by(member: member, poll: @poll_last, group: group)
        expect(poll_group.present?).to be_truthy
      end
    end

    context "create poll to public" do
      it "reponse with a 422 status when point remain 0" do
        post "poll/create.json", { member_id: member.id, title: "eiei", choices: ["A", "B"], type_poll: "freeform", creator_must_vote: true, allow_comment: true, is_public: true }, { "Accept" => "application/json"}
        @poll_last = Poll.unscoped.last
        expect(response.status).to eq(422)
        expect(json["response_message"]).to eq(ExceptionHandler::Message::Poll::POINT_ZERO)
      end

      it "can post poll to public when user's point more than 0" do
        member.update!(point: 1)
        post "poll/create.json", { member_id: member.id, title: "eiei", choices: ["A", "B"], type_poll: "freeform", creator_must_vote: true, allow_comment: true, is_public: true }, { "Accept" => "application/json"}
        @poll_last = Poll.unscoped.last
        poll_public = PollMember.find_by(member: member, poll: @poll_last, public: true)
        expect(response.status).to eq(201)
        expect(poll_public.present?).to be_truthy
      end
    end
  end

  describe "POST /poll/:id/un_see" do
    it "creates unsee" do

      post "/poll/#{poll.id}/un_see", { member_id: member.id }, { "Accept" => "application/json" }

      expect(response.status).to eq(201)

      expect(json["response_status"]).to eq("OK")

      expect(NotInterestedPoll.count).to eq(1)
    end

    it "cannot unsee poll" do
      NotInterestedPoll.create!(member_id: member.id, unseeable: poll)

      post "/poll/#{poll.id}/un_see", { member_id: member.id }, { "Accept" => "application/json" }
      expect(response.status).to eq(422)
      expect(json["response_status"]).to eq("ERROR")
      expect(json["response_message"]).to eq("You have already unsee this poll.")
      expect(NotInterestedPoll.count).to eq(1)
    end
  end

  describe "POST /poll/:id/vote" do
    it "can vote" do
      post "/poll/#{poll.id}/vote", { member_id: member.id, choice_id: choice_one.id }, { "Accept" => "application/json" }

      expect(response.status).to eq(200)
      expect(json["response_status"]).to eq("OK")
      expect(json.has_key?("information")).to be true
      # expect(json.has_key?("scroll")).to be true
      expect(json.has_key?("vote_max")).to be true
      expect(json.has_key?("choices")).to be_truthy
      poll.reload
      choice_one.reload
      expect(poll.vote_all).to eq(1)
      expect(choice_one.vote).to eq(1)
    end

    it "can not vote when not found poll" do
      post "/poll/1/vote", { member_id: member.id, choice_id: choice_one.id }, { "Accept" => "application/json" }

      expect(json["response_status"]).to eq("ERROR")
      expect(json["response_message"]).to eq(ExceptionHandler::Message::Poll::NOT_FOUND)
    end

    it "can not vote when not found choice" do
      post "/poll/#{poll.id}/vote", { member_id: member.id, choice_id: 1 }, { "Accept" => "application/json" }

      expect(json["response_status"]).to eq("ERROR")
      expect(json["response_message"]).to eq("Choice not found.")
    end

    it "reponse with a 422 status when poll was closed" do
      poll.update(close_status: true)
      post "/poll/#{poll.id}/vote", { member_id: member.id, choice_id: 1 }, { "Accept" => "application/json" }

      expect(response.status).to eq(422)
      expect(json["response_message"]).to eq(ExceptionHandler::Message::Poll::CLOSED)
    end

    it "reponse with a 422 status when poll was expired" do
      poll.update(expire_status: true, expire_date: 1.days.ago)
      post "/poll/#{poll.id}/vote", { member_id: member.id, choice_id: 1 }, { "Accept" => "application/json" }
      expect(response.status).to eq(422)
      expect(json["response_message"]).to eq(ExceptionHandler::Message::Poll::EXPIRED)
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

  describe "POST /poll/:id/unsee" do
    before do
      create(:save_poll_later, member: member, savable: poll)
    end

    it "has 1 save poll later" do
      expect(SavePollLater.count).to eq(1)
    end

    it "can hide poll" do
      post "/poll/#{poll.id}/un_see.json", { member_id: member.id }, { "Accept" => "application/json" }

      expect(json["response_status"]).to eq("OK")
    end

    it "has 0 save poll when this poll was unsee" do
      post "/poll/#{poll.id}/un_see.json", { member_id: member.id }, { "Accept" => "application/json" }
      expect(NotInterestedPoll.count).to eq(1)
      expect(SavePollLater.count).to eq(0)
    end
  end


  describe "POST /poll/:id/close" do
    it "close poll" do
      post "/poll/#{poll.id}/close.json", { member_id: member.id }, { "Accept" => "application/json" }

      expect(poll.reload.close_status).to be_truthy
      expect(poll.reload.closed?).to be_truthy

      expect(response.status).to eq(200)

      expect(json["response_status"]).to eq("OK")
    end
  end


  describe "GET /poll/:id/list_mentionable" do
    let!(:group) { create(:group, member: member, name: "my group") }
    let!(:poll_in_group) { create(:poll, title: "post poll in group", member: member, in_group: true) }
    let!(:poll_groups) { create(:poll_group, member: member, poll: poll_in_group, group: group) }

    let!(:group_member_one) { create(:group_member, member: member, group: group, is_master: true, active: true) }
    let!(:group_member_two) { create(:group_member, member: friend, group: group, is_master: false, active: true) }

    let!(:sample_friend_1) { create(:friend, follower: member, followed: friend, active: true, status: 1) }
    let!(:smaple_friend_2) { create(:friend, follower: friend, followed: member, active: true, status: 1) }

    context "in group" do
      before do
        get "/poll/#{poll_in_group.id}/list_mentionable.json", { member_id: member.id }, { "Accept" => "application/json" }
      end

      it "success" do
        expect(response.status).to eq(200)
      end

      it "has 2 mentionable" do
        expect(json["list_mentionable"].size).to eq(2)
      end
    end


    context "in friend and public" do
      before do
        get "/poll/#{poll.id}/list_mentionable.json", { member_id: member.id }, { "Accept" => "application/json" }
      end

      it "success" do
        expect(response.status).to eq(200)
      end

      it "has 1 mentionable" do
        expect(json["list_mentionable"].size).to eq(1)
      end
    end
  end

  describe "DELETE /poll/:id/delete" do

    let!(:poll_for_delete) { create(:poll, member: member, title: "for delete") }

    before do
      delete "/poll/#{poll_for_delete.id}/delete.json", { member_id: member.id }, { "Accept" => "application/json" }
    end

    it "can delete" do
      expect(json["response_status"]).to eq("OK")
    end

    it "update column to deleted_at" do
      expect(poll_for_delete.reload.deleted_at.present?).to eq(true)
    end
  end

  describe "POST /poll/:id/promote_poll" do
    let!(:poll_in_friend) { create(:poll, member: member_with_point, title: "Poll Friend to Public", public: false) }
    let!(:poll_in_friend_member) { create(:poll_member, poll: poll_in_friend, member: member_with_point, public: false ) }

    it "promote poll to public" do
      post "/poll/#{poll_in_friend.id}/promote_poll.json", { member_id: member_with_point.id }, { "Accept" => "application/json" }
      expect(json["response_status"]).to eq("OK")
      expect(response.status).to eq(200)
    end
  end

  describe "POST /poll/scan_qrcode" do
    before do
      post "/scan_qrcode.json", { member_id: member.id, qrcode_key: poll.qrcode_key, id: poll.id }, { "Accept" => "application/json" }
    end

    it "should see detail of poll via scaning qrcode" do
      expect(response.status).to eq(200)
    end
  end

  describe "GET /poll/:id/detail" do
    before do
      get "/poll/#{poll.id}/detail.json", { member_id: member.id }, { "Accept" => "application/json" }
    end

    it "should be all pass" do
      expect(response.status).to eq(200)
    end

    it "should have a response keys equal default keys of poll feed" do
      expect(json.keys.sort).to eq(Poll::KeysPollFeed::KEYS.sort)
    end
  end


end
