require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Member::MemberList" do 
    
  let(:new_member1) { FactoryGirl.create(:member) }
  let(:new_member2) { FactoryGirl.create(:member) }
  let(:new_member3) { FactoryGirl.create(:member) }

  let(:new_member1_action_new_member2) { Member::MemberAction.new(new_member1, new_member2) }
  let(:new_member2_actoin_new_member1) { Member::MemberAction.new(new_member2, new_member1) }

  let(:new_member1_action_new_member3) { Member::MemberAction.new(new_member1, new_member3) }
  let(:new_member3_action_new_member1) { Member::MemberAction.new(new_member3, new_member1) }

  let(:new_member2_action_new_member3) { Member::MemberAction.new(new_member2, new_member3) }
  
  let(:new_member2_viewing_new_member1) { Member::MemberList.new(new_member1, viewing_member: new_member2) } 
  let(:new_member1_member_list) { Member::MemberList.new(new_member1) }
  let(:new_member2_member_list) { Member::MemberList.new(new_member2) }
  let(:new_member3_member_list) { Member::MemberList.new(new_member3) }
  
  context 'Friends' do

    it '- Friends request incoming' do 
      new_member1_action_new_member2.add_friend
      new_member1_action_new_member3.add_friend
      new_member2_action_new_member3.add_friend

      expect(new_member2_member_list.friend_request.map(&:id)).to match_array([new_member1.id])
      expect(new_member3_member_list.friend_request.map(&:id)).to match_array([new_member1.id, new_member2.id])
    end

    it '- Friends request outgoing' do
      new_member1_action_new_member2.add_friend
      new_member1_action_new_member3.add_friend
      new_member2_action_new_member3.add_friend


      expect(new_member2_member_list.outgoing_requests_ids).to match_array([new_member3.id])
      expect(new_member1_member_list.outgoing_requests_ids).to match_array([new_member2.id, new_member3.id])
    end

    it '- Friends of member' do
      new_member1_action_new_member2.add_friend
      new_member1_action_new_member3.add_friend

      new_member2_actoin_new_member1.accept_friend_request
      new_member3_action_new_member1.accept_friend_request

      expect(new_member2_viewing_new_member1.friends_ids).to match_array([new_member2.id, new_member3.id])
    end

  end
end