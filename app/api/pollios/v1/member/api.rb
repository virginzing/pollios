module Pollios::V1::Member
  class API < Grape::API
    version 'v1', using: :path

    resource :members do

      params do
        requires :id, type: Integer, desc: "member id"
      end

      route_param :id do

        desc "returns member detail for profile screen of member"
        get do
          { member: Member.find(params[:id]) }
        end

        desc "returns list of member's friends & followings"
        get '/friends', root: false, serializer: FriendListSerializer do
          member_list = Member::MemberList.new(Member.find(params[:id]))
        end

        desc "returns list of member's groups"
        get '/groups', root: false, serializer: GroupListSerializer do
          group_list = Member::GroupList.new(Member.find(params[:id]))
        end
        
      end 
    end 

  end
end 