require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Member::MemberAction" do

  before (:context) do
    @member_1 = FactoryGirl.create(:member) 
    @member_2 = FactoryGirl.create(:member)
    @celebrity = FactoryGirl.create(:celebrity)
  end

  context 'A member[1] sends add friend request to member[2]' do
    before (:context) do
      @add_friend = Member::MemberAction.new(@member_1, @member_2).add_friend
    end
    
    it '- A member[2] appears in outgoing friend request of member[1]' do
      expect(Member::MemberList.new(@member_1).not_exist_outgoing_request?(@member_2)).to be false
    end 

    it '- A member[1] appears in incoming friend request of member[2]' do
      expect(Member::MemberList.new(@member_2).not_exist_incoming_request?(@member_1)).to be false
    end
  end

  context 'A member[1] sends follow request to celebrity' do
    before do
      @follow = Member::MemberAction.new(@member_1, @celebrity).follow
    end

    it '- A celebrity appears in followings list of member[1]' do
      expect(Member::MemberList.new(@member_1).already_follow_with?(@celebrity)).to be true
    end

    it '- A member[1] appears in follower list of celebrity' do
      expect(Member::MemberList.new(@celebrity).followers).to include(@member_1)
    end
  end

  context 'A member[1] sends unfollow request to celebrity' do
    before do
      @member_action = Member::MemberAction.new(@member_1, @celebrity)
      @follow = @member_action.follow

      @unfollow = @member_action.unfollow
    end

    it '- A celebrity disappears from followings list of member[1]' do
      expect(Member::MemberList.new(@member_1).already_follow_with?(@celebrity)).to be false
    end

     it '- A member[1] disappears from follower list of celebrity' do
      expect(Member::MemberList.new(@celebrity).followers).not_to include(@member_1)
    end
  end

  context 'A member[2] denies friend request from member[1]' do
    before do
      @add_friend = Member::MemberAction.new(@member_1, @member_2).add_friend

      @deny_friend_request = Member::MemberAction.new(@member_2, @member_1).deny_friend_request
    end

    it '- A member[2] disappears from outgoing friend request of member[1]' do
      expect(Member::MemberList.new(@member_1).not_exist_outgoing_request?(@member_2)).to be true
    end 

    it '- A member[1] disappears from incoming friend request of member[2]' do
      expect(Member::MemberList.new(@member_2).not_exist_incoming_request?(@member_1)).to be true
    end
  end

   context 'A member[2] cancels friend request from member[1]' do
    before do
      @member_action = Member::MemberAction.new(@member_1, @member_2)
      @add_friend = @member_action.add_friend

      @cancel_friend_request = @member_action.cancel_friend_request
    end

    it '- A member[2] disappears from outgoing friend request of member[1]' do
      expect(Member::MemberList.new(@member_1).not_exist_outgoing_request?(@member_2)).to be true
    end 

    it '- A member[1] disappears from incoming friend request of member[2]' do
      expect(Member::MemberList.new(@member_2).not_exist_incoming_request?(@member_1)).to be true
    end
  end

  context 'A member[1] blocks member[2]' do
    before do
      @block = Member::MemberAction.new(@member_1, @member_2).block
    end
    
    it '- A member[2] appears in block list of member[1]' do
      expect(Member::MemberList.new(@member_1).already_block_with?(@member_2)).to be true
    end 
  end
end