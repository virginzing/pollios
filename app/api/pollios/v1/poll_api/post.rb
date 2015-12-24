module Pollios::V1::PollAPI
  class Post < Grape::API
    version 'v1', using: :path

    resource :polls do

      desc '[x] create a new poll'
      post do
      end

      params do
        optional :id, type: Integer, desc: 'poll id'
      end

      route_param :id do

        desc '[x] close for voting poll'
        post '/close' do
        end

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

        desc '[x] add to bookmark'
        post '/bookmark' do
        end

        desc '[x] remove from bookmark'
        post '/unbookmark' do
        end

        desc '[x] save for vote later'
        post '/save' do
        end

        desc '[x] turn on notification'
        post '/watch' do
        end

        desc '[x] turn off notification'
        post '/unwatch' do
        end

        desc '[x] not interested'
        post '/not_interest' do
        end

        desc '[x] promote to public poll'
        post '/promote' do
        end

        desc '[x] report poll_id'
        post '/report' do
        end

        resource :comments do
          desc '[x] add comment to poll_id'
          post do
          end

          params do
            requires :comment_id, type: Integer, desc: 'comment_id in poll_id'
          end

          route_param :comment_id do
            desc '[x] reply comment_id'
            post '/reply' do
            end

            desc '[x] report comment_id'
            post '/report' do
            end

            desc '[x] delete comment_id'
            post '/delete' do
            end
          end
        end

      end

    end
  end
end