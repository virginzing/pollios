module Api
  module V2
    class CompaniesController < ApplicationController
      respond_to :json
      
      skip_before_action :verify_authenticity_token

      before_action :get_your_group, only: [:poll_detail]
      before_action :set_current_member, only: [:polls, :poll_detail]
      before_action :set_group, only: [:polls, :poll_detail]
      before_action :load_resource_poll_feed, only: [:polls, :poll_detail]
      # before_action :compress_gzip, only: [:polls, :poll_detail]

      expose(:share_poll_ids) { @current_member.cached_shared_poll.map(&:poll_id) }


      def polls
        @init_poll = PollOfGroup.new(@current_member, @group, options_params)
        @polls = @init_poll.get_poll_of_group_company.paginate(page: params[:next_cursor])
        poll_helper
      end

      def poll_detail
        @poll = Poll.cached_find(params[:id])
        @expired = @poll.expire_date < Time.now
        @voted = @current_member.list_voted?(@poll)

        init_company = PollDetailCompany.new(@group, @poll)
        @member_group = init_company.get_member_in_group
        @member_voted_poll = init_company.get_member_voted_poll
        @member_novoted_poll = init_company.get_member_not_voted_poll
        @member_viewed_poll = init_company.get_member_viewed_poll
        @member_noviewed_poll = init_company.get_member_not_viewed_poll
        @member_viewed_no_vote_poll = init_company.get_member_viewed_not_vote_poll
      end

      def poll_helper
        @poll_series, @poll_nonseries = Poll.split_poll(@polls)
        @group_by_name ||= @init_poll.group_by_name
        @next_cursor = @polls.next_page.nil? ? 0 : @polls.next_page
        @total_entries = @polls.total_entries
      end


      private

      def options_params
        params.permit(:next_cursor, :type, :member_id, :since_id, :pull_request)
      end

      def set_group
        begin
          @group = Group.find(params[:group_id])
          raise ExceptionHandler::NotFound, "Group not found" unless @group.present?
        end
      end

    end
  end
end