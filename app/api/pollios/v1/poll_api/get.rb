module Pollios::V1::PollAPI
  class Get < Grape::API
    version 'v1', using: :path

    helpers do
      def poll
        @poll ||= Poll.cached_find(params[:id])
      end
    end

    resource :polls do
      params do 
        requires :id, type: Integer, desc: "poll id"
      end

      route_param :id do

        desc "returns poll details for requesting member"
        get do
          poll, error_message = Member::PollList.new(current_member).poll(params[:id])
          error! error_message, 401 unless poll
          { poll: poll }
        end
      end

    end

  end 
end