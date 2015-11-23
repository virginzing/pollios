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
        requires :id, type: Integer, desc: 'group_id'
      end

      route_param :id do
        
        desc 'returns group details for group_id'
        get do
          { group: group }
        end

        desc 'returns members of group_id'
        get '/members' do
        end

        desc 'returns polls in group_id'
        get '/polls' do
        end

      end
    end

  end 
end