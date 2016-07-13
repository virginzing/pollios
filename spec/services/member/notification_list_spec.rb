require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Member::NotificationList" do

  # context "#friend: Friend request shows on member[1]'s notification list when" do
  #   before (:context) do
  #     @member_1 = FactoryGirl.create(:member)
  #     @member_2 = FactoryGirl.create(:member)
  #     @member_3 = FactoryGirl.create(:member)
  #   end

  #   it '- Member[1] receives friend request.' do
  #     # Member::MemberAction.new(@member_2, @member_1).add_friend
  #     Notification::Member::FriendsRequest.new(@member_2, @member_1)
  #     # Notification::Member::FriendsRequest.new(@member_3, @member_1)
  #     puts '  '
  #     puts "SHOWME!!! #{Member::NotificationList.new(@member_1).all.map(:recipient_id)}"
  #     puts '  '
  #     # expect ()
  #   end
  # end

#   context '#friend: Accept friend request shows on notification list.' do
#     it '- Member[1] receives accept friend request.' do

#     end
#   end

#   context '#poll: Friends create a poll.' do

#   end

#   context '#poll: create_to_group' do

#   end

#   context '#poll: A member receives a comment.' do

#   end

#   # context '#poll: Other poll that you turn on notification.' do

#   # end

#   context '#poll: someone mention you' do

#   end

#   context '#poll: someone votes on your poll.' do

#   end

#   context '#poll: sum_vote' do

#   end

#   context '#group: Your group has join request ' do

#   end

#   context '#group: someone invite you to a group.' do

#   end

#   context '#group: administrator promoted you to administrator of group.' do

#   end

#   context '#reward: Member[1] got reward from compaign.' do

#   end
end