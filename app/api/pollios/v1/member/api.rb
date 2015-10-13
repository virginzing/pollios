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
          friends_of_member = Member::MemberList.new(Member.find(params[:id]))
        end

        desc "returns list of member's groups"
        get '/groups', root: false, serializer: GroupListSerializer do
          options = {:viewing_member => current_member }
          groups_for_member = Member::GroupList.new(Member.find(params[:id]), options)
        end

        desc "returns list of memebr's rewards"
        get '/rewards', root: false, serializer: RewardListSerializer do
          rewards_of_member = Member::RewardList.new(Member.find(params[:id]))
        end
        
      end 
    end 

  end
end 