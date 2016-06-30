require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Member::MemberAction" do
  
  context 'A member request to add friend' do
    #-- member1 requests to add friend with member2
    before do
      @member1 = FactoryGirl.create(:member, email: Faker::Internet.email) 
      @member2 = FactoryGirl.create(:member, email: Faker::Internet.email)

      @member_list_1 = Member::MemberList.new(@member1)
      @member_list_2 = Member::MemberList.new(@member2)

      @member_action = Member::MemberAction.new(member1,member2)
      @add_friend = @member_action.add_friend
    end
    
    it '- A member appears in outgoing friend request' do
      expect(@member_list_1.not_exist_outgoing_request?(@member2)).to be false
    end 

    it '- A member appears in incoming friend request' do
      expect(@member_list_2.not_exist_incoming_request?(@member1)).to be false
    end

    it '- The request notify to a member' do
      expect(@member_list_1.already_sent_request_to?(@member2)).to be true
    end 
  end

  context 'A member request to follow celebrity' do
    before do
      @member = FactoryGirl.create(:member, email: Faker::Internet.email)
      @celebrity = FactoryGirl.create(:celebrity, email: Faker::Internet.email)

      @member_list = Member::MemberList.new(@member)
      @celebrity_list = Member::MemberList.new(@celebrity)

      @member_action = Member::MemberAction.new(@member,@celebrity)
      @follow = @member_action.follow
    end

    it '- A celebrity appears in followings list of member' do
      expect(@member_list.already_follow_with?(@celebrity)).to be true
    end

    it '- A member appears in follower list of celebrity' do
      expect(@celebrity_list.followers).to include(@member)
    end
  end

  context 'A member request to unfollow celebrity' do
    before do
      @member = FactoryGirl.create(:member, email: Faker::Internet.email)
      @celebrity = FactoryGirl.create(:celebrity, email: Faker::Internet.email)

      @member_list = Member::MemberList.new(@member)
      @celebrity_list = Member::MemberList.new(@celebrity)

      @member_action = Member::MemberAction.new(member1,celebrity)
      @follow = @member_action.follow
      @unfollow = @member_action.unfollow
    end

    it '- A celebrity disappears from followings list of member' do
     expect(@member_list.already_follow_with?(@celebrity)).to be false
     end

     it '- A member disappears from follower list of celebrity' do
      expect(@celebrity_list.followers).not_to include(@member)
    end
  end

  context 'A member denies friend request' do
    #-- member2 denies friend request from member1
    before do
      @member1 = FactoryGirl.create(:member, email: Faker::Internet.email) 
      @member2 = FactoryGirl.create(:member, email: Faker::Internet.email)

      @member_list_1 = Member::MemberList.new(@member1)
      @member_list_2 = Member::MemberList.new(@member2)

      @member_action_1 = Member::MemberAction.new(@member1,@member2)
      @add_friend = @member_action_1.add_friend
      @member_action_2 = Member::MemberAction.new(@member2,@member1)
      @deny_friend_request = @member_action_2.deny_friend_request
    end

    it '- A member disappears from outgoing friend request' do
      expect(@member_list_1.not_exist_outgoing_request?(@member2)).to be true
    end 

    it '- A member disappears from incoming friend request' do
      expect(@member_list_2.not_exist_incoming_request?(@member1)).to be true
    end
  end

   context 'A member cancel friend request' do
    #-- member2 cancel friend request from member1
    before do
      @member1 = FactoryGirl.create(:member, email: Faker::Internet.email) 
      @member2 = FactoryGirl.create(:member, email: Faker::Internet.email)

      @member_list_1 = Member::MemberList.new(@member1)
      @member_list_2 = Member::MemberList.new(@member2)

      @member_action = Member::MemberAction.new(@member1,@member2)
      @add_friend = @member_action.add_friend
      @cancel_friend_request = @member_action.cancel_friend_request
    end

    it '- A member disappears from outgoing friend request' do
      expect(@member_list_1.not_exist_outgoing_request?(@member2)).to be true
    end 

    it '- A member disappears from incoming friend request' do
      expect(@member_list_2.not_exist_incoming_request?(@member1)).to be true
    end
  end

  context 'A member block anather member' do
    #-- member1 block member2
    before do
      @member1 = FactoryGirl.create(:member, email: Faker::Internet.email) 
      @member2 = FactoryGirl.create(:member, email: Faker::Internet.email)

      @member_list_1 = Member::MemberList.new(@member1)
      @member_list_2 = Member::MemberList.new(@member2)

      @member_action = Member::MemberAction.new(@member1,@member2)
      @block = @member_action.block
    end
    
    it '- A member appears in block list' do
      expect(@member_list_1.already_block_with?(@member2)).to be true
    end 
  end
end