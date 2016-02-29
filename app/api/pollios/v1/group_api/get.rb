module Pollios::V1::GroupAPI
  class Get < Grape::API
    version 'v1', using: :path

    helpers do
      def group
        @group ||= Group.cached_find(params[:id])
      end

      def current_member_status
        @current_member_status ||= Member::GroupList.new(current_member).relation_status_ids
      end
    end

    resource :groups do
      params do
        requires :id, type: Integer, desc: 'group id'
      end

      route_param :id do
        
        desc 'returns group details for group_id'
        get do
          present group, with: Pollios::V1::Shared::GroupEntity \
            , current_member_status: current_member_status
        end

        desc 'returns group details with lastest join member for group_id'
        get '/recents' do
          present group, with: Pollios::V1::Shared::GroupWithLastestMemberEntity \
            , current_member_status: current_member_status
        end

        desc 'returns members of group_id'
        get '/members' do
          members_of_group = Group::MemberList.new(group, viewing_member: current_member)
          present members_of_group, with: MemberListEntity \
            , current_member: current_member \
            , current_member_linkage: Member::MemberList.new(current_member).social_linkage_ids
        end

        desc 'returns polls in group_id'
        params do
          optional :index, type: Integer, desc: "starting index for polls's list in this request"
        end
        get '/polls' do
          polls_of_groups = Group::PollList.new(group, viewing_member: current_member, index: params[:index])
          present polls_of_groups, poll: :polls, with: Pollios::V1::Shared::PollListEntity \
            , current_member: current_member \
            , current_member_states: Member::PollList.new(current_member).member_states_ids
        end

        desc "returns group's settings details"
        get '/settings' do
          present group, with: PrivacyEntity, current_member: current_member
        end
      end
    end

  end 
end