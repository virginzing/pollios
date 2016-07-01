require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Member::PollAction" do

  before(:context) do
    @poll_creator = FactoryGirl.create(:member)
    @friend = FactoryGirl.create(:member)
    @member = FactoryGirl.create(:member)

    @creator_member_action = Member::MemberAction.new(@poll_creator, @friend)
    @friend_member_action = Member::MemberAction.new(@friend, @poll_creator)
    @add_friend = @friend_member_action.add_friend
    @accept_friend = @creator_member_action.accept_friend_request
  end

  context '#create: A member creates poll, became owner of the poll' do
    before(:context) do
      @poll_params = FactoryGirl.attributes_for(:poll)
      @poll = Member::PollAction.new(@poll_creator).create(@poll_params)
    end

    it '- A member could create a poll' do
      expect(@poll).to be_valid
    end

    it '- A member is an owner of the poll' do
      expect(@poll_creator.id).to eq(@poll.member_id)
    end

    it '- A poll default is friends and followings' do
      expect(@poll.public).to be false
    end
    
  end

  context '#delete: A member deletes his poll' do
    before(:context) do
      @poll_params = FactoryGirl.attributes_for(:poll)
      @poll = Member::PollAction.new(@poll_creator).create(@poll_params)

      @member_poll_action = Member::PollAction.new(@member, @poll)
      @creator_poll_action = Member::PollAction.new(@poll_creator, @poll)
    end

    it '- A member who is owner this poll could delete this poll' do
      expect { @creator_poll_action.delete }.not_to raise_error
    end

    it '- A poll that deletes must have value of deleted_at' do
      expect(@poll.deleted_at).not_to eq(nil)
    end

  end

  context '#delete: A member deletes another member poll' do
    before(:context) do
      @poll_params = FactoryGirl.attributes_for(:poll, :choice_params)
      @poll = Member::PollAction.new(@poll_creator).create(@poll_params)

      @member_poll_action = Member::PollAction.new(@member, @poll)
      @creator_poll_action = Member::PollAction.new(@poll_creator, @poll)
    end

    it '- A member who is not owner this poll could not deletes this poll' do
      expect { @member_poll_action.delete } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, "You're not owner this poll.")
    end

  end

  context '#vote: A member votes own poll when poll creator must not vote' do
    before(:context) do
      @poll_params = FactoryGirl.attributes_for(:poll)
      @poll = Member::PollAction.new(@poll_creator).create(@poll_params)
      @poll.creator_must_vote = false
      @creator_poll_action = Member::PollAction.new(@poll_creator, @poll)
    end

    it '- Owner of the Poll could not vote for their own poll' do
      expect { @creator_poll_action.vote(choice_id: @poll.choices.first.id) } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, "This poll isn't allow your own vote.")
    end

  end

  context '#vote: A member votes poll of friend or following' do
    before(:context) do
      @poll_params = FactoryGirl.attributes_for(:poll)
      @poll = Member::PollAction.new(@poll_creator).create(@poll_params)
      @friend_poll_action = Member::PollAction.new(@friend, @poll)
      @creator_poll_action = Member::PollAction.new(@poll_creator, @poll)
    end

    it '- A friend member could votes this poll' do
      expect { @friend_poll_action.vote(choice_id: @poll.choices.first.id) } \
        .not_to raise_error
    end

  end

  context '#vote: A member votes poll of another member who is not friend' do
    before(:context) do
      @poll_params = FactoryGirl.attributes_for(:poll)
      @poll = Member::PollAction.new(@poll_creator).create(@poll_params)
      @member_poll_action = Member::PollAction.new(@member, @poll)
    end

    it '- A member who is not friend or following with poll creator could not votes this poll' do
      expect { @member_poll_action.vote(choice_id: @poll.choices.first.id) } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, 'This poll is allow vote for friends or following.')
    end

  end

  context '#bookmark: A member bookmarks poll of friend' do
    before(:context) do
      @poll_params = FactoryGirl.attributes_for(:poll)
      @poll = Member::PollAction.new(@poll_creator).create(@poll_params)
      @friend_poll_action = Member::PollAction.new(@friend, @poll)
    end

    it '- A friend member could bookmark a poll' do
      expect { @friend_poll_action.bookmark }.not_to raise_error
    end

    it '- A friend member could not bookmark a poll which already bookmark' do
      @friend_poll_action.bookmark
      expect { @friend_poll_action.bookmark } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, 'You are already bookmarked this poll.')
    end

  end

end