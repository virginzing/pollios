require 'rails_helper'
require 'guard_message'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Member::MemberAction" do

  context '#add_friend: A member[1] sends add friend request to member[2]' do
    before (:context) do
      @member_1 = FactoryGirl.create(:member) 
      @member_2 = FactoryGirl.create(:member)
      
      @add_friend = Member::MemberAction.new(@member_1, @member_2).add_friend
    end
   
    it '- A member[2] appears in outgoing friend request list of member[1]' do
      expect(Member::MemberList.new(@member_1).not_exist_outgoing_request?(@member_2)).to be false
    end 

    it '- A member[1] appears in incoming friend request list of member[2]' do
      expect(Member::MemberList.new(@member_2).not_exist_incoming_request?(@member_1)).to be false
    end
  end

context '#add_friend: A member[1] fails to send add friend request to member[2]' do
    before(:context) do
      @member_1 = FactoryGirl.create(:member) 
      @member_2 = FactoryGirl.create(:member)
    end

    it '- A member[1] can not add self as a friend' do
      expect{ Member::MemberAction.new(@member_1, @member_1).add_friend } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, " #{add_self_as_a_friend_message} ")
    end

    it '- they are already friends' do
      @add_friend = Member::MemberAction.new(@member_1, @member_2).add_friend
      @accept_friend_request = Member::MemberAction.new(@member_2, @member_1).accept_friend_request

      expect{ Member::MemberAction.new(@member_1, @member_2).add_friend } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, " #{already_friend_message(@member_2)} ")
    end

    it '- A member[1] already sent request' do
      @add_friend = Member::MemberAction.new(@member_1, @member_2).add_friend

      expect{ Member::MemberAction.new(@member_1, @member_2).add_friend } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, " #{already_sent_request_message(@member_2)} ")
    end

    it '- A member[1] blocked member[2]' do
      @block = Member::MemberAction.new(@member_1, @member_2).block

      expect{ Member::MemberAction.new(@member_1, @member_2).add_friend } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, " #{already_blocked_message(@member_2)} ")
    end
  end

  context '#follow: A member[1] sends follow request to celebrity_member' do
    before(:context) do
      @member_1 = FactoryGirl.create(:member) 
      @celebrity_member = FactoryGirl.create(:celebrity_member)

      @follow = Member::MemberAction.new(@member_1, @celebrity_member).follow
    end

    it '- A celebrity_member appears in following list of member[1]' do
      expect(Member::MemberList.new(@member_1).already_follow_with?(@celebrity_member)).to be true
    end

    it '- A member[1] appears in follower list of celebrity_member' do
      expect(Member::MemberList.new(@celebrity_member).followers).to include(@member_1)
    end
  end

  context '#follow: A member[1] fails to send follow request to celebrity_member' do
    before(:context) do
      @member_1 = FactoryGirl.create(:member)
      @member_2 = FactoryGirl.create(:member)
      @celebrity_member = FactoryGirl.create(:celebrity_member)
    end
    it '- A celebrity_member can not follow self' do
      expect{ Member::MemberAction.new(@celebrity_member, @celebrity_member).follow } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, " #{follow_self_message} ")
    end

    it '- A member[1] are already followed celebrity_member' do
      @follow = Member::MemberAction.new(@member_1, @celebrity_member).follow 

      expect{ Member::MemberAction.new(@member_1, @celebrity_member).follow } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, " #{already_followed_message} ")
    end

    it '- A friend requestmember[2] is not official account' do
      expect{ Member::MemberAction.new(@member_1, @member_2).follow  } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, " #{not_official_account_message} ")
    end

    # it '- A celebrity_member blocked member[1]' do
    #   @block = Member::MemberAction.new(@celebrity_member, @member_1).block

    #   expect{ Member::MemberAction.new(@member_1, @celebrity_member).follow  } \
    #     .to raise_error(ExceptionHandler::UnprocessableEntity, " #{blocking_message(@celebrity_member)} ")
    # end
  end

  context '#unfollow: A member[1] sends unfollow request to celebrity_member' do
    before(:context) do
      @member_1 = FactoryGirl.create(:member) 
      @celebrity_member = FactoryGirl.create(:celebrity_member)

      @member_action = Member::MemberAction.new(@member_1, @celebrity_member)
      @follow = @member_action.follow

      @unfollow = @member_action.unfollow
    end

    it '- A celebrity_member disappears from followings list of member[1]' do
      expect(Member::MemberList.new(@member_1).already_follow_with?(@celebrity_member)).to be false
    end

     it '- A member[1] disappears from follower list of celebrity_member' do
      expect(Member::MemberList.new(@celebrity_member).followers).not_to include(@member_1)
    end
  end
 
  context '#unfollow: A member[1] fails to send unfollow request to celebrity_member' do
    before(:context) do
      @member_1 = FactoryGirl.create(:member)
      @celebrity_member = FactoryGirl.create(:celebrity_member)
    end
    it '- A member[1] can not send unfollow themself' do
      expect{ Member::MemberAction.new(@celebrity_member, @celebrity_member).unfollow  } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, " #{unfollow_self_message} ")
    end

    it '- A member[1] are not following member[2]' do
      expect{ Member::MemberAction.new(@member_1, @celebrity_member).unfollow  } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, " #{not_following_message} ")
    end
  end

  context '#deny: A member[2] denies friend request from member[1]' do
    before(:context) do
      @member_1 = FactoryGirl.create(:member) 
      @member_2 = FactoryGirl.create(:member)

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

  context '#deny: A member[2] fails to #deny friend request from member[1]' do
    before(:context) do
      @member_1 = FactoryGirl.create(:member) 
      @member_2 = FactoryGirl.create(:member)
      @celebrity_member = FactoryGirl.create(:celebrity_member)
    end
    # it '- A member[1] does not send add friend request' do
    #   expect{ Member::MemberAction.new(@celebrity_member, @celebrity_member).deny_friend_request } \
    #     .to raise_error(ExceptionHandler::UnprocessableEntity, " #{not_exist_incoming_request_message(@member_1)} ")
    # end
  end

  context '#cancel: A member[2] cancels friend request from member[1]' do
    before(:context) do
      @member_1 = FactoryGirl.create(:member) 
      @member_2 = FactoryGirl.create(:member)

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

  context '#cancel: A member[2] fails to #cancel friend request from member[1]' do
    before(:context) do
      @member_1 = FactoryGirl.create(:member) 
      @member_2 = FactoryGirl.create(:member)
    end

    # it '- A member[1] dose not send add friend request' do
    #   expect{ Member::MemberAction.new(@celebrity_member, @celebrity_member).cancel_friend_request } \
    #     .to raise_error(ExceptionHandler::UnprocessableEntity, " #{not_exist_outgoing_request_message} ")
    # end
  end

  context '#block: A member[1] #blocks member[2]' do
    before(:context) do
      @member_1 = FactoryGirl.create(:member) 
      @member_2 = FactoryGirl.create(:member)

      @block = Member::MemberAction.new(@member_1, @member_2).block
    end
    
    it '- A member[2] appears in block list of member[1]' do
      expect(Member::MemberList.new(@member_1).already_block_with?(@member_2)).to be true
    end 
  end

  context '#block: A member[1] fails to #block member[2]' do
    before(:context) do
      @member_1 = FactoryGirl.create(:member) 
      @member_2 = FactoryGirl.create(:member)
    end
    it '- A member[1] can not block self' do
      expect{ Member::MemberAction.new(@member_1, @member_1).block } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, " #{block_self_message} ")
    end
    it '- A member[1] already blocked member[2]' do
      @block = Member::MemberAction.new(@member_1, @member_2).block

      expect{ Member::MemberAction.new(@member_1, @member_2).block } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, " #{already_blocked_message(@member_2)} ")
    end
  end
end