require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Member::MemberAction" do

  let(:member1) { FactoryGirl.create(:member, email: Faker::Internet.email) } 
  let(:member2) { FactoryGirl.create(:member, email: Faker::Internet.email) }
  let(:celebrity) { FactoryGirl.create(:celebrity, email: Faker::Internet.email) }

  let(:member_list1) { Member::MemberList.new(member1) }
  let(:member_list2) { Member::MemberList.new(member2) }
  let(:celebrity_list) { Member::MemberList.new(celebrity) }

  context 'A member request to add friend' do
    #-- member1 requests to add friend with member2
    before do
      @member_action = Member::MemberAction.new(member1,member2)
      @add_friend = @member_action.add_friend
    end
    
    it '- A member appears in outgoing friend request' do
      expect(member_list1.not_exist_outgoing_request?(member2)).to be false
    end 

    it '- A member appears in incoming friend request' do
      expect(member_list2.not_exist_incoming_request?(member1)).to be false
    end

    it '- The request notify to a member' do
      expect(member_list1.already_sent_request_to?(member2)).to be true
      expect(Member::NotificationList.new(member2).all_notification).to include(member1)
    end 
  end

  context 'A member request to follow celebrity' do
    before do
      @member_action = Member::MemberAction.new(member1,celebrity)
      @follow = @member_action.follow
    end

    it '- A celebrity appears in followings list of member' do
      expect(member_list1.already_follow_with?(celebrity)).to be true
    end

    it '- A member appears in follower list of celebrity' do
      expect(celebrity_list.followers).to include(member1)
    end
  end

  context 'A member request to unfollow celebrity' do
    before do
      @member_action = Member::MemberAction.new(member1,celebrity)
      @follow = @member_action.follow
      @unfollow = @member_action.unfollow
    end

    it '- A celebrity disappears from followings list of member' do
     expect(member_list1.already_follow_with?(celebrity)).to be false
       expect(member_list1.followings).not_to include(celebrity)
    end

     it '- A member disappears from follower list of celebrity' do
      expect(celebrity_list.followers).not_to include(member1)
    end
  end

  context 'A member denies friend request' do
    #-- member2 denies friend request from member1
    before do
      @member_action1 = Member::MemberAction.new(member1,member2)
      @add_friend = @member_action1.add_friend
      @member_action2 = Member::MemberAction.new(member2,member1)
      @deny_friend_request = @member_action2.deny_friend_request
    end

    it '- A member disappears from outgoing friend request' do
      expect(member_list1.not_exist_outgoing_request?(member2)).to be true
    end 

    it '- A member disappears from incoming friend request' do
      expect(member_list2.not_exist_incoming_request?(member1)).to be true
    end
  end

   context 'A member cancel friend request' do
    #-- member2 cancel friend request from member1
    before do
      @member_action = Member::MemberAction.new(member1,member2)
      @add_friend = @member_action.add_friend
      @cancel_friend_request = @member_action.cancel_friend_request
    end

    it '- A member disappears from outgoing friend request' do
      expect(member_list1.not_exist_outgoing_request?(member2)).to be true
    end 

    it '- A member disappears from incoming friend request' do
      expect(member_list2.not_exist_incoming_request?(member1)).to be true
    end
  end

end