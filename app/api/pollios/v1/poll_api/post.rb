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

      desc 'create a new poll'
      params do
        requires :title, type: String, desc: 'poll title'
        requires :choices, type: Array[String], desc: 'poll choices'
        requires :type_poll, type: String, values: %w(rating freeform), desc: 'poll choices type'

        optional :allow_comment, type: Boolean, default: true, desc: 'true if allows comments'
        optional :creator_must_vote, type: Boolean, default: true, desc: 'creator must vote to see result'
        optional :public, type: Boolean, desc: 'true if public poll' 
        optional :group_ids, type: Array[Integer], desc: 'group-ids to create/post in'

        optional :photo_poll, type: String, desc: 'URL for photo to be displayed'
        optional :original_images, type: Array[String], desc: 'URL for original photos'
        optional :thumbnail_type, type: Integer, values: [0, 1, 2, 3, 4, 5], desc: 'index of layout of display photo_poll'

        exactly_one_of :public, :group_ids
        all_or_none_of :photo_poll, :original_images, :thumbnail_type
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
          desc 'vote choice_id on poll_id'
          params do
            requires :choice_id, type: Integer, desc: 'choice_id to vote on'
            optional :anonymous, type: Boolean, default: false, desc: 'true if voting as anonymous'
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
          desc 'add comment to poll_id'
          params do
            requires :message, type: String, desc: 'comment message'
            optional :mention_ids, type: Array[Integer], desc: 'list of member (ids) for mention on comment'
          end
          post do
            comment = current_member_poll_action.comment(params)
            present comment, with: CommentDetailEntity, current_member: current_member
          end

          route_param :comment_id do
            desc 'report comment_id in poll_id'
            params do
              requires :comment_id, type: Integer, desc: 'comment_id in poll_id'
              requires :message_preset, type: String, desc: 'as inappropriate because'
              optional :message, type: String, default: '', desc: 'additional information'
            end
            post '/report' do
              report_comment = current_member_poll_action.report_comment(params)
              present report_comment, with: CommentDetailEntity, current_member: current_member
            end
          end
        end

      end

    end
  end
end