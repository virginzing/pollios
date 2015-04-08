class AppReportListReportPolls

  PER_PAGE = 50

  def initialize(params = {})
    @params = params
  end

  def next_cursor_report_polls
    @params[:next_cursor] = 1 if @params[:next_cursor].to_i == 0
    @params[:next_cursor] || 1
  end

  def get_list_report_polls
    @get_list_report_polls = query_report_polls
  end

  def get_next_cursor
    get_list_report_polls.next_page.nil? ? 0 : get_list_report_polls.next_page
  end

  def total_list_report_polls
    get_list_report_polls.total_entries
  end


  private

  def query_report_polls
    query = Poll.includes(:member).having_status_poll(:gray).where("report_count != 0 AND in_group = 'f'").order("report_count desc, created_at desc")
    query = query.paginate(per_page: PER_PAGE, page: next_cursor_report_polls)
    query
  end
  
end