module Pollios::V1::Member
  class API < Grape::API
    version 'v1', using: :path

    resource :members do

      params do
        requires :id, type: Integer, desc: "member id"
      end

      before do
        @member = Member.cached_find(params[:id])
      end

      helpers do
        def verify_viewing_member_right
          error!("403 Forbidden: not allowing this operation on other member", 403) unless @member.id == current_member.id
        end
      end

      route_param :id do

        desc "returns member detail for profile screen of member"
        get do
          { member: @member }
        end

        desc "returns list of member's friends & followings"
        resource :friends do
          get do
             friends_of_member = Member::MemberList.new(@member)
             present friends_of_member, with: Pollios::V1::Member::FriendListEntity, current_member: current_member
          end
        end

        desc "returns list of member's groups"
        resource :groups do
          get do
            options = {:viewing_member => current_member }
            groups_for_member = Member::GroupList.new(@member, options)
            present groups_for_member, with: Pollios::V1::Member::GroupListEntity, current_member: current_member
          end
        end

        desc "returns list of member's rewards"
        resource :rewards do
          get do
            rewards_of_member = Member::RewardList.new(@member)
            present rewards_of_member, with: Pollios::V1::Member::RewardListEntity, current_member: current_member
          end
        end
        
        desc "returns list of member's notifications"
        resource :notifications do
          params do
            optional :page_index, type: Integer, desc: "page index for notification's pagination"
            optional :clear_new_count, type: Boolean, desc: "should clear member's new notification count"
          end
          get do
            verify_viewing_member_right
            notifications_for_member = Member::NotificationList.new(@member, {:page_index => params[:page_index], :clear_new_count => params[:clear_new_count]})
            present notifications_for_member, with: Pollios::V1::Member::NotificationListEntity, current_member: current_member
          end
        end
      end 
    end 

  end
end 