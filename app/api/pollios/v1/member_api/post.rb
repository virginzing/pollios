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
      end
    end
  end
end