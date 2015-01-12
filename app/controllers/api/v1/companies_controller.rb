module Api
  module V1
    class CompaniesController < ApplicationController
      respond_to :json

      skip_before_action :verify_authenticity_token

      before_action :set_current_member

      before_action :load_resource_poll_feed, only: [:polls, :poll_detail, :company_polls]
      
      before_action :get_your_group, only: [:poll_detail, :polls]
      before_action :set_group, only: [:polls, :poll_detail]

      before_action :compress_gzip
      before_action :set_company

      before_action :set_poll_series, only: [:questionnaire_detail, :load_suggest]

      expose(:share_poll_ids) { @current_member.cached_shared_poll.map(&:poll_id) }
      expose(:group_company) { @current_member.get_company.groups if @current_member }

      def polls
        @init_poll = PollOfGroup.new(@current_member, @group, options_params)
        @polls = @init_poll.get_poll_of_group.paginate(page: params[:next_cursor])
        poll_helper
      end

      def poll_detail
        @poll = Poll.cached_find(params[:id])
        init_company = PollDetailCompany.new(@poll.groups, @poll)
        @member_group = init_company.get_member_in_group
        @member_voted_poll = init_company.get_member_voted_poll
        @member_novoted_poll = init_company.get_member_not_voted_poll
        @member_viewed_poll = init_company.get_member_viewed_poll
        @member_noviewed_poll = init_company.get_member_not_viewed_poll
        @member_viewed_no_vote_poll = init_company.get_member_viewed_not_vote_poll
      end

      def questionnaire_detail
        # init_company = QuestionnaireDetailCompany
      end

      def load_suggest
        @suggests = Suggest.joins(:member)
                          .select("suggests.*, members.fullname as member_fullname, members.avatar as member_avatar")
                          .where(poll_series_id: suggest_params[:id]).order("suggests.created_at desc")
                          .paginate(page: suggest_params[:next_cursor])
                          
        @new_suggest_sort = @suggests.sort { |x,y| x.created_at <=> y.created_at }
        @suggests_as_json = ActiveModel::ArraySerializer.new(@new_suggest_sort, each_serializer: SuggestSerializer).as_json()
        @next_cursor = @suggests.next_page.nil? ? 0 : @suggests.next_page
        @total_entries = @suggests.total_entries
      end

      def poll_helper
        @next_cursor = @polls.next_page.nil? ? 0 : @polls.next_page
        @total_entries = @polls.total_entries
      end

      ## main of company ##

      def company_groups
        @groups = Group.eager_load(:group_company, :poll_groups, :group_members).where("group_companies.company_id = #{@company.id}").uniq
      end

      def company_members
        @members = Member.includes(:groups).where("groups.id IN (?) AND group_members.active = 't'", @company.groups.map(&:id)).uniq.references(:groups)
      end

      def company_polls
        @init_poll = PollOfGroup.new(@current_member, @company.groups, options_params)
        @polls = @init_poll.get_poll_of_group_company.paginate(page: params[:next_cursor])
        @next_cursor = @polls.next_page.nil? ? 0 : @polls.next_page
        @total_entries = @polls.total_entries
      end

      private

      def options_params
        params.permit(:next_cursor, :type, :member_id, :since_id, :pull_request)
      end

      def set_company
        @company = @current_member.get_company
      end

      def suggest_params
        params.permit(:next_cursor, :member_id, :id, :group_id)
      end

      def set_poll_series
        begin
        @poll_series = PollSeries.find(params[:id])
        rescue => e
          respond_to do |wants|
            wants.json { render json: Hash["response_status" => "ERROR", "response_message" => "Questionnaire not found"], status: 404 }
          end
        end
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