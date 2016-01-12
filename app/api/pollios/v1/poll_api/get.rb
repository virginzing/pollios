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
    end

    resource :polls do
      params do 
        optional :id, type: Integer, desc: 'poll id'
      end

      desc '[x] returns default poll-timeline for requesting member'
      get do
        # member_poll_lister.default_timeline
      end

      desc '[x] returns public poll-timeline for requesting member'
      get '/public' do
      end

      desc '[x] returns friends & followings poll-timeline for requesting member'
      get '/friends' do
      end

      desc '[x] returns group poll-timeline for requesting member'
      get '/group' do
      end

      route_param :id do

        desc 'returns poll details for requesting member'
        get do
          poll_detail = member_poll_inqury.view
          present poll_detail, with: Pollios::V1::Shared::PollDetailEntity, current_member: current_member
        end

        resource :comments do
          desc "returns list of poll[id]'s comments"
          get do
            comments = Poll::CommentList.new(poll, viewing_member: current_member).comments
            present comments, with: CommentDetailEntity, current_member: current_member
          end
        end

        resource :members do
          desc "returns list of poll[id]'s voters"
          get '/voters' do
            members_voted = Poll::MemberList.new(poll, viewing_member: current_member)
            present members_voted, with: MemberVotedDetailEntity, current_member: current_member
          end
        end
      end

    end

  end 
end