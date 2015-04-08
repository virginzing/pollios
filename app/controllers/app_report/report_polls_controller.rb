module AppReport
  class ReportPollsController < ApplicationController

    skip_before_action :verify_authenticity_token

    before_action :set_poll, only: [:detail, :ban, :no_ban]
    
    expose(:poll) { @poll }

    respond_to :json
    
    def list_polls
      init_list_polls ||= AppReportListReportPolls.new(report_polls_params)

      @list_polls = init_list_polls.get_list_report_polls
      @next_cursor = init_list_polls.get_next_cursor
      @total_entries = init_list_polls.total_list_report_polls
    end

    def detail
      @list_reason = @poll.member_report_polls.limit(500).includes(:member)
    end

    def ban
      unless @poll.update!(status_poll: :black)
        raise ExceptionHandler::UnprocessableEntity, "Unable banned, please try again"
      end
    end

    def no_ban
      unless @poll.update!(status_poll: :white)
        raise ExceptionHandler::UnprocessableEntity, "Unable no ban, please try again"
      end
    end

    private

    def set_poll
      @poll = Poll.cached_find(params[:id])
    end

    def report_polls_params
      params.permit(:next_cursor)
    end

  end
end