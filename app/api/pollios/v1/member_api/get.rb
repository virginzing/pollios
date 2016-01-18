module Pollios::V1::MemberAPI
  class Get < Grape::API
    version 'v1', using: :path

    helpers do
      def member
        @member ||= Member.viewing_by_member(current_member).cached_find(params[:id])
      end
    end

    resource :members do
      params do
        requires :id, type: Integer, desc: 'member id'
      end

      route_param :id do

        desc 'returns member detail for profile screen of member'
        get do
          present member, with: Pollios::V1::Shared::MemberEntity, current_member: current_member
        end

        desc "returns list of member's friends & followings"
        resource :friends do
          get do
            friends_of_member = Member::MemberList.new(member, viewing_member: current_member)
            present friends_of_member, with: FriendListEntity, current_member: current_member
          end
        end

        desc "returns list of member's groups"
        resource :groups do
          get do
            groups_for_member = Member::GroupList.new(member, viewing_member: current_member)
            present groups_for_member, with: GroupListEntity, current_member: current_member
          end
        end

        resource :polls do

          desc "returns list of member's created poll"
          get '/created' do
            polls_for_member = Member::PollList.new(member, viewing_member: current_member)
            present :created, polls_for_member.created, with: Pollios::V1::Shared::PollDetailEntity \
              , current_member: current_member
          end

          desc "returns list of member's voted poll"
          get '/voted' do
            polls_for_member = Member::PollList.new(member, viewing_member: current_member)
            present :voted, polls_for_member.voted, with: Pollios::V1::Shared::PollDetailEntity, current_member: current_member
          end
        end

      end

    end

  end 
end 