require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Poll::MemberList" do

  let(:new_poll) { FactoryGirl.create(:poll) }
  
  let(:new_member1) { FactoryGirl.create(:member, email: Faker::Internet.email) }
  let(:new_member2) { FactoryGirl.create(:member, email: Faker::Internet.email) }
  let(:new_member3) { FactoryGirl.create(:member, email: Faker::Internet.email) }
  let(:new_member4) { FactoryGirl.create(:member, email: Faker::Internet.email) }
  let(:new_member5) { FactoryGirl.create(:member, email: Faker::Internet.email) }
  let(:new_member6) { FactoryGirl.create(:member, email: Faker::Internet.email) }

  let(:new_member1_viewing_new_poll) { Poll::MemberList.new(new_poll, new_member1) }
  let(:new_member2_viewing_new_poll) { Poll::MemberList.new(new_poll, viewing_member: new_member2) }

  let(:new_member1_poll_action) { Member::PollAction.new(new_member1, new_poll) }
  let(:new_member2_poll_action) { Member::PollAction.new(new_member2, new_poll) }
  let(:new_member3_poll_action) { Member::PollAction.new(new_member3, new_poll) }

  let(:new_member1_action_new_member2) { Member::MemberAction.new(new_member1, new_member2) }
  let(:new_member2_member_list) { Member::MemberList.new(new_member2) }

  context 'Voteing' do

    it '- Voter viewing by members without incoming block' do
      new_member1_poll_action.vote(choice_id: new_poll.choices.first.id) 
      new_member2_poll_action.vote(choice_id: new_poll.choices.first.id) 
      new_member3_poll_action.vote(choice_id: new_poll.choices.second.id)
      
      expect(new_member1_viewing_new_poll.voter).to match_array([new_member1, new_member2, new_member3])
    end

    it '- Voter viewing by members coming block' do
      new_member1_poll_action.vote(choice_id: new_poll.choices.first.id) 
      new_member2_poll_action.vote(choice_id: new_poll.choices.first.id) 
      new_member3_poll_action.vote(choice_id: new_poll.choices.second.id)
      new_member1_action_new_member2.block

      expect(new_member2_viewing_new_poll.voter).to match_array([new_member2, new_member3])
    end

    it '- Voter viewing by members as by anonymous' do
      new_member1_poll_action.vote(choice_id: new_poll.choices.first.id, anonymous: 'true')
      new_member2_poll_action.vote(choice_id: new_poll.choices.first.id)
      new_member3_poll_action.vote(choice_id: new_poll.choices.second.id)

      expect(new_member2_viewing_new_poll.voter).to match_array([new_member2, new_member3])
    end
  end

  context 'Mentionable' do

    it '- Voter can mentionable by members' do
      new_member1_poll_action.vote(choice_id: new_poll.choices.first.id)
      new_member2_poll_action.vote(choice_id: new_poll.choices.second.id)
      new_member3_poll_action.vote(choice_id: new_poll.choices.second.id)

      expect(new_member1_viewing_new_poll.mentionable).to match_array([])
    end
end