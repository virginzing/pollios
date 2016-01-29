module Pollios::V1::GroupAPI
  class Delete < Grape::API
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

        resource :polls do
          params do
            requires :poll_id, type: Integer, desc: 'poll id'
          end
          route_param :poll_id do
            
            desc 'delete poll_id in group_id'
            delete '/delete' do
              Member::GroupAction.new(current_member, group).delete_poll(params[:poll_id])
            end

          end
        end

      end
    end

  end
end