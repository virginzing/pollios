module Pollios::V1::PollAPI
  class Get < Grape::API
    version 'v1', using: :path

    helpers do
      def poll
        @poll ||= Poll.cached_find(params[:id])
      end

      def member_poll_lister
        @member_poll_lister ||= Member::PollList.new(current_member)
      end

      def member_poll_inqury
        @member_poll_inqury ||= Member::PollInquiry.new(current_member, poll)
      end

      def poll_member_listing(choice_id = nil)
        @poll_member_listing ||= Poll::MemberList.new(poll, viewing_member: current_member \
          , index: params[:index], choice_id: choice_id)
      end

      def member_poll_feed
        @member_poll_feed ||= Member::PollFeed.new(current_member, index: params[:index])
      end
    end

    resource :polls do

      params do
        optional :index, type: Integer, desc: "starting index for polls's list in this request"
      end
      resource :timeline do
        desc 'returns default poll-timeline for requesting member'
        get do
          present member_poll_feed, poll: :default_timeline, with: Pollios::V1::Shared::PollListEntity \
            , current_member: current_member
        end

        desc 'returns unvoted poll-timeline for requesting member'
        get '/unvoted' do
          present member_poll_feed, poll: :unvoted_timeline, with: Pollios::V1::Shared::PollListEntity \
            , current_member: current_member
        end

        desc 'returns public poll-timeline for requesting member'
        get '/public' do
          present member_poll_feed, poll: :public_timeline, with: Pollios::V1::Shared::PollListEntity \
            , current_member: current_member
        end

        desc 'returns friends & followings poll-timeline for requesting member'
        get '/friends' do
          present member_poll_feed, poll: :friends_timeline, with: Pollios::V1::Shared::PollListEntity \
            , current_member: current_member
        end

        desc 'returns group poll-timeline for requesting member'
        get '/group' do
          present member_poll_feed, poll: :group_timeline, with: Pollios::V1::Shared::PollListEntity \
            , current_member: current_member
        end
      end

      params do 
        requires :id, type: Integer, desc: 'poll id'
      end
      
      route_param :id do

        desc 'returns poll details for requesting member'
        get do
          poll_detail = member_poll_inqury.view
          present poll_detail, with: Pollios::V1::Shared::PollDetailEntity, current_member: current_member
        end

        resource :comments do
          desc "returns list of poll[id]'s comments"
          params do
            optional :index, type: Integer, desc: "starting index for comments's list in this request"
          end
          get do
            comments_of_poll = Poll::CommentList.new(poll, viewing_member: current_member, index: params[:index])
            present comments_of_poll, with: CommentListEntity, current_member: current_member
          end
        end

        resource :members do
          desc "returns list of poll[id]'s voters"
          params do
            optional :index, type: Integer, desc: "starting index for members's list in this request"
          end
          get '/voters' do
            present poll_member_listing, member: :voter, with: MemberVotedDetailEntity, current_member: current_member
          end

          desc "returns list of poll[id]'s mentionable"
          get '/mentionable' do
            present :members, poll_member_listing.mentionable, with: MemberInPollEntity, current_member: current_member
          end
        end

        resource :choices do
          desc "returns list of choices[id]'s voters"
          params do
            requires :choice_id, type: Integer, desc: 'choice_id in poll_id'
          end

          route_param :choice_id do
            get '/voters' do
              present poll_member_listing(params[:choice_id]), member: :voter, with: MemberVotedDetailEntity \
                , current_member: current_member
            end
          end
        end

      end
    end

  end 
end