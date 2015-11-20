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
          current_member_action.unfriend
        end

        desc 'block member_id'
        post '/block' do
          current_member_action.block
        end

        desc 'unblock member_id'
        post '/unblock' do
          current_member_action.unblock
        end

        desc 'follow member_id'
        post '/follow' do
          current_member_action.follow
        end

        desc 'unfollow member_id'
        post '/unfollow' do
          current_member_action.unfollow
        end

        resource :request do
          desc 'accept friend request from member_id'
          post '/accept' do
            current_member_action.accept_friend_request
          end

          desc 'deny friend request from member_id'
          post '/deny' do
            current_member_action.deny_friend_request
          end

          desc 'cancel friend request'
          post '/cancel' do
            current_member_action.cancel_friend_request
          end
        end

      end
    end
  end
end