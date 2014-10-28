class Company::CompanyReportPoll
  def initialize(group_list)
    @group_list = group_list
  end

  def group_ids
    @group_list.map(&:id)
  end

  def get_report_poll_in_company
    report_poll_in_company
  end

  private

  def report_poll_in_company
    Poll.joins(:member_report_polls, :poll_groups)
    .includes(:groups, :member)
    .where("polls.in_group = 't' AND poll_groups.group_id IN (?)", group_ids).uniq
  end


end
