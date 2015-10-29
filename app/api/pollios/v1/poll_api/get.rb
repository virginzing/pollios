module Pollios::V1::PollAPI
  class Get < Grape::API
    version 'v1', using: :path

    helpers do
      def poll
        @poll ||= Poll.find(params[:id])
      end
    end

    resource :polls do
      params do 
        requires :id, type: Integer, desc: "poll id"
      end

      route_param :id do

        desc "returns member detail for profile screen of member"
        get do
          { poll: poll }
        end
      end

    end

  end 
end