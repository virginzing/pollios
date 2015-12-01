module Pollios::V1::PollAPI
  class Post < Grape::API
    version 'v1', using: :path

    resource :polls do
      params do
        requires :id, type: Integer, desc: 'poll id'
      end

      route_param :id do

        resource :choices do
          desc '[x] vote choide_id on poll_id'
          params do
            requires :choice_id, type: Integer, desc: 'choice_id to vote on'
          end
          route_param :choice_id do
            post '/vote' do
              { choice: params[:choice_id] }
            end 
          end
        end

      end

    end
  end
end