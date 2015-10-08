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
        get '/friends' do
          member_list = Member::MemberList.new(Member.find(params[:id]))
           { friends: member_list.friends,
             followers: member_list.follower,
             followings: member_list.following,
             blocks: member_list.block }
        end

        desc "returns list of member's groups"
        get '/groups' do
          m = Member.find(params[:id])
          { admin: [m],
            active: [m]}
        end
        
      end 
    end 

  end
end 