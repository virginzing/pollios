require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Poll::CommentList" do

  let(:new_poll) { FactoryGirl.create(:poll) }

  let(:new_member1) { FactoryGirl.create(:member) }
  let(:new_member2) { FactoryGirl.create(:member) }
  let(:new_member3) { FactoryGirl.create(:member) }

  let(:new_member1_poll_action) { Member::PollAction.new(new_member1, new_poll) }  
  let(:new_member2_poll_action) { Member::PollAction.new(new_member2, new_poll) }
  let(:new_member3_poll_action) { Member::PollAction.new(new_member3, new_poll) }

  let(:new_member3_poll_comment_list) { Poll::CommentList.new(new_poll, viewing_member: new_member3) }
  
  context 'Comment' do
    
    it '- Voter viewing by comments' do
      new_member1_poll_action.vote(choice_id: new_poll.choices.first.id)
      new_member2_poll_action.vote(choice_id: new_poll.choices.second.id)
      new_member3_poll_action.vote(choice_id: new_poll.choices.second.id)

      new_member1_poll_action.comment(message: 'test comment member1')
      new_member2_poll_action.comment(message: 'test comment member2')

      expect(new_member3_poll_comment_list.comments.map(&:id)).to \
        match_array(new_poll.comments.map(&:id))
    end
  end
end