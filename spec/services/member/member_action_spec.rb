require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Member::MemberAction" do

  context '#add_friend: A member[1] sends add friend request to member[2]' do
    before (:context) do
      @member_1 = FactoryGirl.create(:member) 
      @member_2 = FactoryGirl.create(:member)
      @celebrity = FactoryGirl.create(:celebrity)
      @add_friend = Member::MemberAction.new(@member_1, @member_2).add_friend
    end
   
    it '- A member[2] appears in outgoing friend request of member[1]' do
      expect(Member::MemberList.new(@member_1).not_exist_outgoing_request?(@member_2)).to be false
    end 

    it '- A member[1] appears in incoming friend request of member[2]' do
      expect(Member::MemberList.new(@member_2).not_exist_incoming_request?(@member_1)).to be false
    end
  end

  # context '#add_friend: A member[1] fails to send add friend request to member[2]' do
  #   before(:context) do
  #     @member_1 = FactoryGirl.create(:member) 
  #     @member_2 = FactoryGirl.create(:member)
  #     @celebrity = FactoryGirl.create(:celebrity)
  #   end

  #   it '- A member[1] can not add themself as a friend' do
  #     expect{ Member::MemberAction.new(@member_1, @member_1).add_friend } \
  #       .to raise_error(ExceptionHandler::UnprocessableEntity, "You can't add yourself as a friend.")
  #   end

  #   it '- A member[1] can not send add friend request to member[2] if they are already friends' do
  #     @add_friend = Member::MemberAction.new(@member_1, @member_2).add_friend
  #     @accept_friend_request = Member::MemberAction.new(@member_2, @member_1).accept_friend_request

  #     expect{ Member::MemberAction.new(@member_1, @member_2).add_friend } \
  #       .to raise_error(ExceptionHandler::UnprocessableEntity, "You and #{@member_2.get_name} are already friends.")
  #   end

  #   it '- A member[1] can not send add friend request to member[2] if member[1] already sent request' do
  #     @add_friend = Member::MemberAction.new(@member_1, @member_2).add_friend

  #     expect{ Member::MemberAction.new(@member_1, @member_2).add_friend } \
  #       .to raise_error(ExceptionHandler::UnprocessableEntity, "You already sent friend request to #{@member_2.get_name}.")
  #   end

  #   it '- A member[1] can not send add friend request to member[2] if member[1] block member[2]' do
  #     @block = Member::MemberAction.new(@member_1, @member_2).block

  #     expect{ Member::MemberAction.new(@member_1, @member_2).add_friend } \
  #       .to raise_error(ExceptionHandler::UnprocessableEntity, "You are currently blocking #{@member_2.get_name}.")
  #   end
  # end

  context '#follow: A member[1] sends follow request to celebrity' do
    before(:context) do
      @member_1 = FactoryGirl.create(:member) 
      @member_2 = FactoryGirl.create(:member)
      @celebrity = FactoryGirl.create(:celebrity)
      @follow = Member::MemberAction.new(@member_1, @celebrity).follow
    end

    it '- A celebrity appears in followings list of member[1]' do
      expect(Member::MemberList.new(@member_1).already_follow_with?(@celebrity)).to be true
    end

    it '- A member[1] appears in follower list of celebrity' do
      expect(Member::MemberList.new(@celebrity).followers).to include(@member_1)
    end
  end

  # context '#follow: A member[1] fails to send follow request to celebrity' do
  #   before(:context) do
  #     @member_1 = FactoryGirl.create(:member) 
  #     @member_2 = FactoryGirl.create(:member)
  #     @celebrity = FactoryGirl.create(:celebrity)
  #   end
  #   it '- A celebrity can not follow themself' do
  #     expect{ Member::MemberAction.new(@celebrity, @celebrity).follow } \
  #       .to raise_error(ExceptionHandler::UnprocessableEntity, "You can't follow yourself.")
  #   end

  #   it '- A member[1] can not send follow request to member[2] if member[1] are already followed member[2]' do
  #     @follow = Member::MemberAction.new(@member_1, @celebrity).follow 

  #     expect{ Member::MemberAction.new(@member_1, @celebrity).follow } \
  #       .to raise_error(ExceptionHandler::UnprocessableEntity, "You already followed this account.")
  #   end

  #   it '- A member[1] can not send follow request to member[2] if member[2] is not official account' do
  #     expect{ Member::MemberAction.new(@member_1, @member_2).follow  } \
  #       .to raise_error(ExceptionHandler::UnprocessableEntity, "This member is not official account.")
  #   end

  #   it '- A member[1] can not send follow request to member[2] if member[1] block member[2]' do
  #     @block = Member::MemberAction.new(@member_1, @celebrity).block

  #     expect{ Member::MemberAction.new(@member_1, @celebrity).follow  } \
  #       .to raise_error(ExceptionHandler::UnprocessableEntity, "You are currently blocking #{@celebrity.get_name}.")
  #   end
  # end

  context '#unfollow: A member[1] sends unfollow request to celebrity' do
    before(:each) do
      @member_1 = FactoryGirl.create(:member) 
      @member_2 = FactoryGirl.create(:member)
      @celebrity = FactoryGirl.create(:celebrity)
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
 
  # context '#unfollow: A member[1] fails to send unfollow request to celebrity' do
  #   before(:context) do
  #     @member_1 = FactoryGirl.create(:member) 
  #     @member_2 = FactoryGirl.create(:member)
  #     @celebrity = FactoryGirl.create(:celebrity)
  #   end
  #   it '- A member[1] can not send unfollow themself' do
  #     expect{ Member::MemberAction.new(@celebrity, @celebrity).unfollow  } \
  #       .to raise_error(ExceptionHandler::UnprocessableEntity, "You can't unfollow yourself.")
  #   end

  #   it '- A member[1] can not send add follow member[2] if member[1] are not following member[2]' do
  #     expect{ Member::MemberAction.new(@member_1, @celebrity).unfollow  } \
  #       .to raise_error(ExceptionHandler::UnprocessableEntity, "You are not following this account.")
  #   end
  # end

  context '#deny: A member[2] denies friend request from member[1]' do
    before(:each) do
      @member_1 = FactoryGirl.create(:member) 
      @member_2 = FactoryGirl.create(:member)
      @celebrity = FactoryGirl.create(:celebrity)
      @add_friend = Member::MemberAction.new(@member_1, @member_2).add_friend

      @deny_friend_request = Member::MemberAction.new(@member_2, @member_1).deny_friend_request
    end

    it '- A member[2] disappears from outgoing friend request list of member[1]' do
      expect(Member::MemberList.new(@member_1).not_exist_outgoing_request?(@member_2)).to be true
    end 

    it '- A member[1] disappears from incoming friend request list of member[2]' do
      expect(Member::MemberList.new(@member_2).not_exist_incoming_request?(@member_1)).to be true
    end
  end

  # context '#deny: A member[2] fails to #deny friend request from member[1]' do
  #   before(:context) do
  #     @member_1 = FactoryGirl.create(:member) 
  #     @member_2 = FactoryGirl.create(:member)
  #     @celebrity = FactoryGirl.create(:celebrity)
  #   end
  #   it '- A member[1] can not deny friend request to member[2] if member[2] is not official account' do
  #     expect{ Member::MemberAction.new(@celebrity, @celebrity).deny_friend_request } \
  #       .to raise_error(ExceptionHandler::UnprocessableEntity, "This request is not existing.")
  #   end
  # end

  context '#cancel: A member[2] cancels friend request from member[1]' do
    before(:context) do
      @member_1 = FactoryGirl.create(:member) 
      @member_2 = FactoryGirl.create(:member)
      @celebrity = FactoryGirl.create(:celebrity)
      @member_action = Member::MemberAction.new(@member_1, @member_2)
      @add_friend = @member_action.add_friend

      @cancel_friend_request = @member_action.cancel_friend_request
    end

    it '- A member[2] disappears from outgoing friend request list of member[1]' do
      expect(Member::MemberList.new(@member_1).not_exist_outgoing_request?(@member_2)).to be true
    end 

    it '- A member[1] disappears from incoming friend request list of member[2]' do
      expect(Member::MemberList.new(@member_2).not_exist_incoming_request?(@member_1)).to be true
    end
  end

  # context '#cancel: A member[2] fails to #cancel friend request from member[1]' do
  #   before(:context) do
  #     @member_1 = FactoryGirl.create(:member) 
  #     @member_2 = FactoryGirl.create(:member)
  #     @celebrity = FactoryGirl.create(:celebrity)
  #   end
  #   it '- A member[1] can not send cancel friend request to member[2] if member[1] has not send add friend request yet' do
  #     expect{ Member::MemberAction.new(@celebrity, @celebrity).cancel_friend_request } \
  #       .to raise_error(ExceptionHandler::UnprocessableEntity, "This request is not existing.")
  #   end
  # end

  context '#block: A member[1] #blocks member[2]' do
    before(:context) do
      @member_1 = FactoryGirl.create(:member) 
      @member_2 = FactoryGirl.create(:member)
      @celebrity = FactoryGirl.create(:celebrity)
      @block = Member::MemberAction.new(@member_1, @member_2).block
    end
    
    it '- A member[2] appears in block list of member[1]' do
      expect(Member::MemberList.new(@member_1).already_block_with?(@member_2)).to be true
    end 
  end

  # context '#block: A member[1] fails to #block member[2]' do
  #   before(:context) do
  #     @member_1 = FactoryGirl.create(:member) 
  #     @member_2 = FactoryGirl.create(:member)
  #     @celebrity = FactoryGirl.create(:celebrity)
  #   end
  #   it '- A member[1] can not block themself' do
  #     expect{ Member::MemberAction.new(@member_1, @member_1).block } \
  #       .to raise_error(ExceptionHandler::UnprocessableEntity, "You can't block yourself.")
  #   end
  #   it '- A member[1] can not block member[2] if member[1] already blocked member[2]' do
  #     @block = Member::MemberAction.new(@member_1, @member_2).block

  #     expect{ Member::MemberAction.new(@member_1, @member_2).block } \
  #       .to raise_error(ExceptionHandler::UnprocessableEntity, "You already blocked #{@member_2.get_name}.")
  #   end
  # end
end