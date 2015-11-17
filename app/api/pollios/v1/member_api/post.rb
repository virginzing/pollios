module Pollios::V1::MemberAPI
  class Post < Grape::API
    version 'v1', using: :path

    helpers do
      def member
        @member ||= Member.cached_find(params[:id])
      end

      def current_member_action
        @current_member_action ||= Member::MemberAction.new(current_member, member)
      end
    end

    resource :members do
      params do
        requires :id, type: Integer, desc: 'member id'
      end

      route_param :id do

        desc 'send add friend request to member_id'
        post '/add_friend' do
          current_member_action.add_friend
        end

        desc 'unfriend member_id'
        post '/unfriend' do
        end

        desc 'block member_id'
        post '/block' do
        end

        desc 'unblock member_id'
        post '/unblock' do
        end

        desc 'follow member_id'
        post '/follow' do
        end

        desc 'unfollow member_id'
        post '/unfollow' do
        end

        # Maybe these two should really belong to 'request'-api ....
        # but putting them here will do for now
        desc 'accept friend request from member_id'
        post '/accept_friend' do
        end

        desc 'deny friend request from member_id'
        post '/deny_friend' do
        end

      end
    end
  end
end