class Admin::ReportPoll

  def get_report_poll
    report_in_friend_and_public
  end

  private

  def report_in_friend_and_public
    Poll.having_status_poll(:gray, :white).where("report_count != 0 AND in_group = 'f'")
  end
  
  
end