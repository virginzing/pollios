module Pollios::V1::Member
  class API < Grape::API
    version 'v1', using: :path

    resource :members do

      before do
        @member = Member.cached_find(params[:id])
      end

      params do
        requires :id, type: Integer, desc: "member id"
      end

      route_param :id do

        desc "returns member detail for profile screen of member"
        get do
          { member: @member }
        end

        desc "returns list of member's friends & followings"
        get '/friends' do
           friends_of_member = Member::MemberList.new(@member)
           present friends_of_member, with: Pollios::V1::Member::FriendListEntity, current_member: current_member
        end

        desc "returns list of member's groups"
        get '/groups' do
          options = {:viewing_member => current_member }
          groups_for_member = Member::GroupList.new(@member, options)
          present groups_for_member, with: Pollios::V1::Member::GroupListEntity, current_member: current_member
        end

        desc "returns list of member's rewards"
        get '/rewards' do
          rewards_of_member = Member::RewardList.new(@member)
          present rewards_of_member, with: Pollios::V1::Member::RewardListEntity, current_member: current_member
        end
        
        desc "returns list of member's notifications"
        get '/notifications' do
          notifications_for_member = Member::NotificationList.new(@member)
          present notifications_for_member, with: Pollios::V1::Member::NotificationListEntity, current_member: current_member
        end
      end 
    end 

  end
end 