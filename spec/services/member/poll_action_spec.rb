require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Member::PollAction" do

  before(:context) do
    @poll_creator = FactoryGirl.create(:member)
    @friend = FactoryGirl.create(:member)
    @member = FactoryGirl.create(:member)

    Member::MemberAction.new(@poll_creator, @friend).add_friend
    Member::MemberAction.new(@friend, @poll_creator).accept_friend_request
  end

  context '#create: Member creates poll.' do
    before(:context) do
      @poll_params = FactoryGirl.attributes_for(:poll)
      @poll = Member::PollAction.new(@poll_creator).create(@poll_params)
    end

    it '- Member can create poll according to aciton.' do
      expect(Member::PollList.new(@poll_creator).created.include?(@poll)).to be true
    end
  end

  context '#delete: Member deletes their poll.' do
    before(:context) do
      @poll_params = FactoryGirl.attributes_for(:poll)
      @poll = Member::PollAction.new(@poll_creator).create(@poll_params)

      @creator_poll_action = Member::PollAction.new(@poll_creator, @poll)
    end

    it '- Member can delete their poll.' do
      @creator_poll_action.delete
      expect(Member::PollList.new(@poll_creator).created.include?(@poll)).to be false
    end

    it '- Poll which is deletes must have value of deleted_at.' do
      expect(@poll.deleted_at).not_to eq(nil)
    end
  end

  context '#delete: Member cannot delete poll when.' do
    before(:context) do
      @poll_params = FactoryGirl.attributes_for(:poll)
      @poll = Member::PollAction.new(@poll_creator).create(@poll_params)

      @member_poll_action = Member::PollAction.new(@member, @poll)
      @creator_poll_action = Member::PollAction.new(@poll_creator, @poll)
    end

    it '- Member deletes poll which not own.' do
      expect { @member_poll_action.delete } \
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::Poll.not_owner_poll)
    end
  end

  context '#vote: Member votes poll.' do
    before(:context) do
      @poll_params = FactoryGirl.attributes_for(:poll, :with_creator_must_vote)
      @poll = Member::PollAction.new(@poll_creator).create(@poll_params)

      @creator_poll_action = Member::PollAction.new(@poll_creator, @poll)
      @friend_poll_action = Member::PollAction.new(@friend, @poll)
    end

    it '- Creator must vote poll.' do
      expect { @creator_poll_action.vote(choice_id: @poll.choices.first.id) } \
        .not_to raise_error
    end

    it '- Friend member can vote poll.' do
      @friend_poll_action.vote(choice_id: @poll.choices.first.id)
      expect(Member::PollList.new(@friend).voted.include?(@poll)).to be true
    end
  end

  context '#vote: Member cannot vote poll which closed or expired.' do
    before(:each) do
      @poll_params = FactoryGirl.attributes_for(:poll)
      @poll = Member::PollAction.new(@poll_creator).create(@poll_params)

      @friend_poll_action = Member::PollAction.new(@friend, @poll)
    end

    it '- The poll is closed.' do
      @poll.update(close_status: true)

      expect { @friend_poll_action.vote(choice_id: @poll.choices.first.id) } \
        .to raise_error(
          ExceptionHandler::Message::Poll::CLOSED,
          GuardMessage::Poll.already_closed)
    end

    it '- The poll is expired.' do
      @poll.update(expire_date: Time.zone.now - 1.weeks)

      expect { @friend_poll_action.vote(choice_id: @poll.choices.first.id) } \
        .to raise_error(
          ExceptionHandler::Message::Poll::EXPIRED,
          GuardMessage::Poll.already_expired)
    end
  end

  context '#vote: Member cannot vote when do not have permission.' do
    before(:each) do
      @poll_params = FactoryGirl.attributes_for(:poll)
      @poll = Member::PollAction.new(@poll_creator).create(@poll_params)

      @creator_poll_action = Member::PollAction.new(@poll_creator, @poll)
      @friend_poll_action = Member::PollAction.new(@friend, @poll)
      @member_poll_action = Member::PollAction.new(@member, @poll)
    end

    it '- Member votes poll which only for friends and following.' do
      expect { @member_poll_action.vote(choice_id: @poll.choices.first.id) } \
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::Poll.only_for_frineds_or_following)
    end

    it '- Creator votes their poll which not allow your own vote.' do
      expect { @creator_poll_action.vote(choice_id: @poll.choices.first.id) } \
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::Poll.not_allow_your_own_vote)
    end

    it '- Member votes poll which already voted.' do
      @friend_poll_action.vote(choice_id: @poll.choices.first.id)

      expect { @friend_poll_action.vote(choice_id: @poll.choices.first.id) } \
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::Poll.already_voted)
    end

    it '- Member already blocked.' do
      Member::MemberAction.new(@poll_creator, @friend).block

      expect { @friend_poll_action.vote(choice_id: @poll.choices.first.id) } \
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::Poll.poll_incoming_block)
    end
  end

  context '#bookmark: Member bookmarks poll.' do
    before(:context) do
      @poll_params = FactoryGirl.attributes_for(:poll)
      @poll = Member::PollAction.new(@poll_creator).create(@poll_params)

      @friend_poll_action = Member::PollAction.new(@friend, @poll)
    end

    it '- Friend member could bookmark a poll.' do
      @friend_poll_action.bookmark
      expect(Member::PollList.new(@friend).bookmarks.include?(@poll)).to be true
    end
  end

  context '#bookmark: Member cannot bookmarks poll when.' do
    before(:context) do
      @poll_params = FactoryGirl.attributes_for(:poll)
      @poll = Member::PollAction.new(@poll_creator).create(@poll_params)

      @friend_poll_action = Member::PollAction.new(@friend, @poll)
    end

    it '- Member cannot bookmark poll which not interest.' do
      @friend_poll_action.not_interest
      expect { @friend_poll_action.bookmark } \
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::Poll.already_not_interest)
    end

    it '- Member cannot bookmark poll which already bookmark.' do
      @friend_poll_action.bookmark
      expect { @friend_poll_action.bookmark } \
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::Poll.already_bookmarked)
    end
  end

  context '#unbookmark: Member unbookmarks poll.' do
    before(:context) do
      @poll_params = FactoryGirl.attributes_for(:poll)
      @poll = Member::PollAction.new(@poll_creator).create(@poll_params)

      @friend_poll_action = Member::PollAction.new(@friend, @poll)
    end

    it '- Member can unbookmark poll which is bookmarked.' do
      @friend_poll_action.bookmark
      expect(Member::PollList.new(@friend).bookmarks.include?(@poll)).to be true

      @friend_poll_action.unbookmark
      expect(Member::PollList.new(@friend).bookmarks.include?(@poll)).to be false
    end
  end

  context '#unbookmark: Member cannot unbookmarks poll when.' do
    before(:context) do
      @poll_params = FactoryGirl.attributes_for(:poll)
      @poll = Member::PollAction.new(@poll_creator).create(@poll_params)

      @friend_poll_action = Member::PollAction.new(@friend, @poll)
    end

    it '- Member cannot unbookmark poll which is not bookmarked.' do
      expect { @friend_poll_action.unbookmark } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, GuardMessage::Poll.not_bookmarked)
    end
  end

  context '#save: Member saves poll.' do
    before(:context) do
      @poll_params = FactoryGirl.attributes_for(:poll)
      @poll = Member::PollAction.new(@poll_creator).create(@poll_params)

      @friend_poll_action = Member::PollAction.new(@friend, @poll)
    end

    it '- Member can save poll.' do
      @friend_poll_action.save
      expect(Member::PollList.new(@friend).saved.include?(@poll)).to be true
    end
  end

  context '#save: Member cannot save poll when.' do
    before(:context) do
      @poll_params = FactoryGirl.attributes_for(:poll)
      @poll = Member::PollAction.new(@poll_creator).create(@poll_params)

      @friend_poll_action = Member::PollAction.new(@friend, @poll)
    end

    it '- Member is already saved poll.' do
      @friend_poll_action.save
      expect { @friend_poll_action.save } \
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::Poll.already_saved)
    end
  end

  context '#close: Member closes their poll.' do
    before(:context) do
      @poll_params = FactoryGirl.attributes_for(:poll)
      @poll = Member::PollAction.new(@poll_creator).create(@poll_params)

      @creator_poll_action = Member::PollAction.new(@poll_creator, @poll)
    end

    it '- Member can close poll.' do
      @creator_poll_action.close
      expect(Member::PollList.new(@poll_creator).closed.include?(@poll)).to be true
    end

    it '- The poll must have close_status equal true.' do
      @creator_poll_action.close
      expect(@poll.close_status).to eq(true)
    end
  end

  context '#close: Member cannot close poll when.' do
    before(:context) do
      @poll_params = FactoryGirl.attributes_for(:poll)
      @poll = Member::PollAction.new(@poll_creator).create(@poll_params)

      @member_poll_action = Member::PollAction.new(@member, @poll)
    end

    it '- Member closes poll which not own.' do
      expect { @member_poll_action.close } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, GuardMessage::Poll.not_owner_poll)
    end
  end

  context '#promote: Member promotes poll.' do
    before(:example) do
      @poll_params = FactoryGirl.attributes_for(:poll)
      @poll = Member::PollAction.new(@poll_creator).create(@poll_params)

      @poll_creator.update(point: 3)
      @creator_poll_action = Member::PollAction.new(@poll_creator, @poll)
    end

    it '- Before promote the poll must not be public.' do
      expect(Member::PollList.new(@poll_creator).created.find(@poll.id).public).to be false
    end

    it '- After promote the poll must be public.' do
      @creator_poll_action.promote
      expect(Member::PollList.new(@poll_creator).created.find(@poll.id).public).to be true
    end

    it "- Member's point must minus one." do
      @creator_poll_action.promote
      expect(@creator_poll_action.member.point).to eq 2
    end
  end

  context '#promote: Member cannot promote poll when.' do
    before(:example) do
      @poll_params = FactoryGirl.attributes_for(:poll)
      @poll = Member::PollAction.new(@poll_creator).create(@poll_params)

      @creator_poll_action = Member::PollAction.new(@poll_creator, @poll)
      @member_poll_action = Member::PollAction.new(@member, @poll)
    end

    it '- Member promotes poll which not own.' do
      expect { @member_poll_action.promote } \
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::Poll.not_owner_poll)
    end

    it '- Member do not have public poll quota.' do
      @poll_creator.point = 0
      expect { @creator_poll_action.promote } \
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::Poll.public_quota_limit_exist)
    end

    it '- The poll is already promoted.' do
      @poll_creator.point = 2
      @creator_poll_action.promote
      expect { @creator_poll_action.promote } \
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::Poll.already_public)
    end

    it '- The poll is already closed.' do
      @creator_poll_action.close
      expect { @creator_poll_action.promote } \
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::Poll.already_closed)
    end
  end

  context '#report: Member reports poll.' do
    before(:context) do
      @poll_params = FactoryGirl.attributes_for(:poll)
      @poll = Member::PollAction.new(@poll_creator).create(@poll_params)

      @friend_poll_action = Member::PollAction.new(@friend, @poll)
    end

    it '- Member can report poll.' do
      @friend_poll_action.report(message_preset: Faker::Lorem.sentence)
      @friend.reload
      expect(Member::PollList.new(@friend).reports.include?(@poll)).to be true
    end
  end

  context '#report: Member cannot report poll when.' do
    before(:context) do
      @poll_params = FactoryGirl.attributes_for(:poll)
      @poll = Member::PollAction.new(@poll_creator).create(@poll_params)

      @creator_poll_action = Member::PollAction.new(@poll_creator, @poll)
    end

    it '- Member cannot report their poll.' do
      expect { @creator_poll_action.report(message_preset: Faker::Lorem.sentence) } \
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::Poll.report_own_poll)
    end
  end

  context '#comment: Member comments poll.' do
    before(:context) do
      @poll_params = FactoryGirl.attributes_for(:poll)
      @poll = Member::PollAction.new(@poll_creator).create(@poll_params)

      @friend_poll_action = Member::PollAction.new(@friend, @poll)
    end

    it '- Member can comment poll.' do
      @friend_poll_action.vote(choice_id: @poll.choices.first.id)
      @poll_comment_list = @friend_poll_action.comment(message: Faker::Lorem.sentence)

      expect(@poll_comment_list.comments.empty?).to be false
    end
  end

  context '#comment: Member cannot comment poll when.' do
    before(:context) do
      @poll_params = FactoryGirl.attributes_for(:poll, :not_allow_comment)
      @poll = Member::PollAction.new(@poll_creator).create(@poll_params)

      @friend_poll_action = Member::PollAction.new(@friend, @poll)
    end

    it '- Member did not vote.' do
      expect { @friend_poll_action.comment(message: Faker::Lorem.sentence) } \
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::Poll.not_voted_and_poll_not_closed)
    end

    it '- Member comments poll which not allow comment.' do
      @friend_poll_action.vote(choice_id: @poll.choices.first.id)
      expect { @friend_poll_action.comment(message: Faker::Lorem.sentence) } \
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::Poll.not_allow_comment)
    end
  end

end