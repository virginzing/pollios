module Pollios::V1
  class PollAPI < Grape::API
    version 'v1', using: :path

    resource :polls do
      get :all_count do
        { count: Poll.count }
      end

      desc "/personal_timeline: returns requesting member's home timeline"
      get :personal_timeline do
      end

      desc "/:id: returns poll detail for requesting member"
      params do
        requires :id, type: Integer, desc: "poll id" 
      end
      route_param :id do
        get do
          { id:  Poll.find(params[:id]) }
        end
      end

    end

  end
end