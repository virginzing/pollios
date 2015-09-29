module Pollios::V1
  class PollAPI < Grape::API
    version 'v1', using: :path

    #TODO: Factorize this into proper API helper
    helpers do

      #TODO: properly authenticate this
      def current_user
        @current_user = nil
      end

      def authenticate!
        error!('401 Unauthorized', 401) unless current_user
      end
    end

    resource :polls do
      get :all_count do
        { count: Poll.count }
      end

      desc "return: requesting member's home timeline"
      get :personal_timeline do
      end

      desc "return: poll detail for requesting member"
      params do
        requires :id, type: Integer, desc: "poll id" 
      end
      route_param :id do
        get do
          authenticate!
          { id:  Poll.find(params[:id]) }
        end
      end

    end

  end
end