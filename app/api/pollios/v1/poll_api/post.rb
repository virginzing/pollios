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
        create = current_member_poll_action.create(params)
        present create, with: Pollios::V1::Shared::PollDetailEntity, current_member: current_member
      end

      params do
        requires :id, type: Integer, desc: 'poll id'
      end

      route_param :id do

        desc 'close for voting poll'
        post '/close' do
          close = current_member_poll_action.close
          present close, with: Pollios::V1::Shared::PollDetailEntity, current_member: current_member
        end

        resource :choices do
          desc 'vote choide_id on poll_id'
          params do
            requires :choice_id, type: Integer, desc: 'choice_id to vote on'
            optional :anonymous, type: Boolean, default: false, desc: 'vote as anonymous'
            optional :data_analysis, type: Hash, desc: 'gender and birthday of member_id for survey'
            optional :surveyor_id, type: Integer, desc: 'surveyor_id'
          end
          route_param :choice_id do
            post '/vote' do
              vote = current_member_poll_action.vote(params)
              present vote, with: Pollios::V1::Shared::PollDetailEntity, current_member: current_member
            end
          end
        end

        desc 'add to bookmark'
        post '/bookmark' do
          bookmark = current_member_poll_action.bookmark
          present bookmark, with: Pollios::V1::Shared::PollDetailEntity, current_member: current_member
        end

        desc 'remove from bookmark'
        post '/unbookmark' do
          unbookmark = current_member_poll_action.unbookmark
          present unbookmark, with: Pollios::V1::Shared::PollDetailEntity, current_member: current_member
        end

        desc 'save for vote later'
        post '/save' do
          save = current_member_poll_action.save
          present save, with: Pollios::V1::Shared::PollDetailEntity, current_member: current_member
        end

        desc 'turn on notification'
        post '/watch' do
          watch = current_member_poll_action.watch
          present watch, with: Pollios::V1::Shared::PollDetailEntity, current_member: current_member
        end

        desc 'turn off notification'
        post '/unwatch' do
          unwatch = current_member_poll_action.unwatch
          present unwatch, with: Pollios::V1::Shared::PollDetailEntity, current_member: current_member
        end

        desc 'not interested'
        post '/not_interest' do
          not_interest = current_member_poll_action.not_interest
          present not_interest, with: Pollios::V1::Shared::PollDetailEntity, current_member: current_member
        end

        desc 'promote to public poll'
        post '/promote' do
          promote = current_member_poll_action.promote
          present promote, with: Pollios::V1::Shared::PollDetailEntity, current_member: current_member
        end

        desc 'report poll_id'
        params do
          requires :message_preset, type: String, desc: 'as inappropriate because'
          optional :message, type: String, default: '', desc: 'additional information'
        end
        post '/report' do
          report = current_member_poll_action.report(params)
          present report, with: Pollios::V1::Shared::PollDetailEntity, current_member: current_member
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