module Pollios::V1::Member
  class API < Grape::API
    version 'v1', using: :path

    helpers do
      def member
        @member ||= Member.cached_find(params[:id])
      end

      def verify_viewing_member_right
        error!("403 Forbidden: not allowing this operation on other member", 403) unless member.id == current_member.id
      end
    end

    resource :members do
      params do
        requires :id, type: Integer, desc: "member id"
      end

      route_param :id do

        desc "returns member detail for profile screen of member"
        get do
          { member: member }
        end

        desc "returns list of member's friends & followings"
        resource :friends do
          get do
             friends_of_member = Member::MemberList.new(member)
             present friends_of_member, with: FriendListEntity, current_member: current_member
          end
        end

        desc "returns list of member's groups"
        resource :groups do
          get do
            options = {:viewing_member => current_member }
            groups_for_member = Member::GroupList.new(member, options)
            present groups_for_member, with: GroupListEntity, current_member: current_member
          end
        end

      end

    end

  end 
end 