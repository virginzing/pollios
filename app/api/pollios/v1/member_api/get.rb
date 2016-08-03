module Pollios::V1::MemberAPI
  class Get < Grape::API
    version 'v1', using: :path

    helpers do
      def member
        @member ||= Member.viewing_by_member(current_member).cached_find(params[:id])
      end

      def current_member_linkage
        @current_member_linkage ||= Member::MemberList.new(current_member).social_linkage_ids
      end
    end

    resource :members do
      params do
        requires :id, type: Integer, desc: 'member id'
      end

      route_param :id do

        desc 'returns member detail for profile screen of member'
        get do
          present member, with: Pollios::V1::Shared::MemberEntity \
            , current_member_linkage: current_member_linkage
        end

        desc 'returns member detail with recents activity for mini profile screen of member'
        get '/recents' do
          present member, with: Pollios::V1::Shared::MemberWithActivityEntity \
           , current_member_linkage: current_member_linkage
        end

        desc "returns list of member's friends & followings"
        resource :friends do
          get do
            friends_of_member = Member::MemberList.new(member, viewing_member: current_member)
            present friends_of_member, with: FriendListEntity \
              , current_member: current_member \
              , current_member_linkage: current_member_linkage
          end
        end

        desc "returns list of member's groups"
        resource :groups do
          get do
            groups_for_member = Member::GroupList.new(member, viewing_member: current_member)
            present groups_for_member, with: GroupListEntity \
              , current_member_status: Member::GroupList.new(current_member).relation_status_ids
          end
        end

        resource :polls do

          helpers do
            def polls_of_member
              @polls_of_member ||= Member::PollList.new(member, viewing_member: current_member, index: params[:index])
            end
          end

          params do
            optional :index, type: Integer, desc: "starting index for polls's list in this request"
          end

          desc "returns list of member's created poll"
          get '/created' do
            present polls_of_member, poll: :created, with: Pollios::V1::Shared::PollListEntity \
              , current_member: current_member \
              , current_member_states: Member::PollList.new(current_member).member_states_ids
          end

          desc "returns list of member's voted poll"
          get '/voted' do
            present polls_of_member, poll: :voted, with: Pollios::V1::Shared::PollListEntity \
              , current_member: current_member \
              , current_member_states: Member::PollList.new(current_member).member_states_ids
          end
        end

      end

    end

  end 
end 