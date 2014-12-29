class Company::CompanyReportPoll
  def initialize(group_list)
    @group_list = group_list.pluck(:id)
  end

  def group_ids
    @group_list.map(&:id)
  end

  def get_report_poll_in_company
    report_poll_in_company
  end

  private

  def report_poll_in_company
    Poll.joins(:member_report_polls).includes(:groups, :member)
    .where("polls.in_group = 't' AND groups.id IN (?)", @group_list).uniq.references(:groups)
  end


end
