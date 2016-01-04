module Pollios::V1::PollAPI
  class Post < Grape::API
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

      desc '[x] create a new poll'
      params do
        requires :title, type: String, desc: 'poll title'
        requires :choices, type: Array[String], desc: 'poll choices'
        requires :type_poll, type: String, values: %w(rating freeform), desc: 'poll choices type'

        optional :allow_comment, type: Boolean, default: true, desc: 'poll allow comments'
        optional :creator_must_vote, type: Boolean, default: true, desc: 'creator must vote poll'
        optional :public, type: Boolean, desc: 'poll post in public' 
        optional :group_ids, type: Array[Integer], desc: 'poll post in group (ids)'
        optional :photo_poll, type: String, desc: 'photo url'
        optional :original_images, type: Array[String], desc: 'original photos url'
        exactly_one_of :public, :group_ids
      end

      post do
        current_member_poll_action.create(params)
      end

      params do
        optional :id, type: Integer, desc: 'poll id'
      end

      route_param :id do

        desc 'close for voting poll'
        post '/close' do
          current_member_poll_action.close
        end

        resource :choices do
          desc '[x] vote choide_id on poll_id'
          params do
            requires :choice_id, type: Integer, desc: 'choice_id to vote on'
          end
          route_param :choice_id do
            post '/vote' do
              current_member_poll_action.vote
              # { choice: params[:choice_id] }
            end 
          end
        end

        desc '[x] add to bookmark'
        post '/bookmark' do
          current_member_poll_action.bookmark
        end

        desc '[x] remove from bookmark'
        post '/unbookmark' do
          current_member_poll_action.unbookmark
        end

        desc '[x] save for vote later'
        post '/save' do
          current_member_poll_action.save
        end

        desc '[x] turn on notification'
        post '/watch' do
          current_member_poll_action.watch
        end

        desc '[x] turn off notification'
        post '/unwatch' do
          current_member_poll_action.unwatch
        end

        desc '[x] not interested'
        post '/not_interest' do
          current_member_poll_action.not_interest
        end

        desc 'promote to public poll'
        post '/promote' do
          current_member_poll_action.promote
        end

        desc '[x] report poll_id'
        post '/report' do
          current_member_poll_action.report
        end

        resource :comments do
          desc '[x] add comment to poll_id'
          post do
            current_member_poll_action.comment
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