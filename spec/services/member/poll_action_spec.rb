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

    it '- A Poll default is not public' do
      expect(@poll.public).to be false
    end
    
  end

end