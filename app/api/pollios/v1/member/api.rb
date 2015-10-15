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
        get '/friends' do
           friends_of_member = Member::MemberList.new(Member.find(params[:id]))
           present friends_of_member, with: Pollios::V1::Member::FriendListEntity, current_member: current_member
        end

        desc "returns list of member's groups"
        get '/groups' do
          options = {:viewing_member => current_member }
          groups_for_member = Member::GroupList.new(Member.find(params[:id]), options)
          present groups_for_member, with: Pollios::V1::Member::GroupListEntity, current_member: current_member
        end

        desc "returns list of memebr's rewards"
        get '/rewards' do
          rewards_of_member = Member::RewardList.new(Member.find(params[:id]))
          present rewards_of_member, with: Pollios::V1::Member::RewardListEntity, current_member: current_member
        end
        
      end 
    end 

  end
end 