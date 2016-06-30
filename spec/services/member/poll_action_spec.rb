require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Member::PollAction" do

  before(:context) do
    @poll_creator = FactoryGirl.create(:member)
    @member = FactoryGirl.create(:member)
  end

  context '#create: A member create poll, became owner of the poll' do
    before(:context) do
      @poll = Member::PollAction.new(@poll_creator).create(FactoryGirl.attributes_for(:poll, :with_choices))
    end

    it '- A member could create a poll' do
      expect(@poll).to be_valid
    end

    it '- A member is an owner of the poll' do
      expect(@poll_creator.id).to eq(@poll.member_id)
    end

    it '- A poll default is not public' do
      expect(@poll.public).to be false
    end
    
  end

  context '#delete: A member delete poll' do
    before(:context) do
      @poll = Member::PollAction.new(@poll_creator).create(FactoryGirl.attributes_for(:poll, :with_choices))
      @member_poll_action = Member::PollAction.new(@member, @poll)
      @creator_poll_action = Member::PollAction.new(@poll_creator, @poll)
    end

    it '- A member who is not owner this poll could not delete this poll' do
      expect{ @member_poll_action.delete }.to raise_error(ExceptionHandler::UnprocessableEntity, "You're not owner this poll.")
    end

    it '- A member who is owner this poll could delete this poll' do
      expect{ @creator_poll_action.delete }.not_to raise_error
    end

    it '- A poll that delete must have value of deleted_at' do
      expect(@poll.deleted_at).not_to eq(nil)
    end
  end

end