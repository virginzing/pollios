module Pollios::V1::Member
  class API < Grape::API
    version 'v1', using: :path
    desc "Member API"

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
        get '/friends', root: false, serializer: FriendSerializer do
          member_list = Member::MemberList.new(Member.find(params[:id]))
        end

        desc "returns list of member's groups"
        get '/groups' do
          group_list = Member::GroupList.new(Member.find(params[:id]))
          { admin: group_list.as_admin,
            member: group_list.as_member }
        end
        
      end 
    end 

  end
end 