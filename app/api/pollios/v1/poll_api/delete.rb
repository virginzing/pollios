module Pollios::V1::PollAPI
  class Delete < Grape::API
    version 'v1', using: :path

    helpers do
      def poll
        @poll ||= poll_or_nil
      end

      def poll_or_nil
        return nil unless params[:id].present?
        Poll.cached_find(params[:id])
      end

      def current_member_poll_action
        @current_member_poll_action ||= Member::PollAction.new(current_member, poll)
      end
    end

    resource :polls do
      params do
        requires :id, type: Integer, desc: 'poll id'
      end

      route_param :id do
        desc 'delete poll_id'
        delete '/delete' do
          current_member_poll_action.delete
        end

        resource :comments do
          route_param :comment_id do
            desc 'delete comment_id in poll_id'
            params do
              requires :comment_id, type: Integer, desc: 'comment_id in poll_id'
            end
            delete '/delete' do
              delete_comment = current_member_poll_action.delete_comment(params)
              present delete_comment, with: CommentDetailEntity, current_member: current_member
            end
          end
        end
      end
      
    end

  end
end