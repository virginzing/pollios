class Company::CompanyReportPoll
  def initialize(group_list, company)
    @group_list = group_list.map(&:id)
    @company = company
  end

  def group_ids
    @group_list.map(&:id)
  end

  def company_member
    @company.member
  end

  def get_report_poll_in_company
    report_poll_in_company
  end

  def get_report_only_exclusive_groups
    report_poll_only_exclusive_groups
  end

  private

  def report_poll_in_company
    Poll.without_deleted.joins(:member_report_polls).includes(:groups, :member, :poll_company)
        .where("(polls.in_group = 't' AND groups.id IN (?)) OR polls.member_id = ? OR poll_companies.company_id = ?", @group_list, company_member.id, @company.id).uniq.references(:groups)
  end

  def report_poll_only_exclusive_groups
    Poll.without_deleted.joins(:member_report_polls).includes(:groups, :member, :poll_company)
        .where("(polls.in_group = 't' AND groups.id IN (?) AND groups.public = 'f')", @group_list).uniq.references(:groups)
  end

end
