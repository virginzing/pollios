module Pollios::V1::GroupAPI
  class Get < Grape::API
    version 'v1', using: :path

    helpers do
      def group
        @group ||= Group.cached_find(params[:id])
      end
    end

    resource :groups do
      params do
        requires :id, type: Integer, desc: 'group id'
      end

      route_param :id do
        
        desc 'returns group details for group_id'
        get do
          present group, with: Pollios::V1::Shared::GroupEntity, current_member: current_member
        end

        desc 'returns members of group_id'
        get '/members' do
          members_of_group = Group::MemberList.new(group, viewing_member: current_member)
          present members_of_group, with: MemberListEntity, current_member: current_member
        end

        desc 'returns polls in group_id'
        get '/polls' do
          polls_of_groups = Group::PollList.new(group, viewing_member: current_member).polls
          present polls_of_groups, with: Pollios::V1::Shared::PollDetailEntity, current_member: current_member
        end

      end
    end

  end 
end