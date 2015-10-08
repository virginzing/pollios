module Pollios::V1
  class PollAPI < Grape::API
    version 'v1', using: :path

    helpers do
      def set_poll
        @poll = Poll.find(params[:id])
      end
    end

    resource :polls do
      
      desc "returns requesting member's home timeline"
      get :personal_timeline do
      end

      desc "returns poll detail for requesting member"
      params do
        requires :id, type: Integer, desc: "poll id" 
      end
      route_param :id do
        get do
          { poll: Poll.find(params[:id]) }
        end
      end

    end

  end
end