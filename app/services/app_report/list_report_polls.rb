class AppReportListReportPolls

  PER_PAGE = 50

  def initialize(params = {})
    @params = params
  end

  def next_cursor_report_polls
    @params[:next_cursor] || 1
  end

  def get_list_report_polls
    @get_list_report_polls ||= query_report_polls
  end

  def get_next_cursor
    get_list_report_polls.next_page.nil? ? 0 : get_list_report_polls.next_page
  end

  def total_list_report_polls
    get_list_report_polls.total_entries
  end

  private

  def query_report_polls
    query = Poll.having_status_poll(:gray, :white).where("report_count != 0 AND in_group = 'f'")
    query = query.paginate(per_page: PER_PAGE, page: next_cursor_report_polls)
    query
  end
  
end