class Company::ListPoll

  def initialize(company)
    @company = company
  end

  def list_polls
    @list_polls ||= Poll.without_deleted.includes([:groups, :poll_company]).where("groups.id IN (?) OR poll_companies.company_id = ?", list_groups, @company.id).uniq.references(:groups, :poll_company)
  end
  
  def access_poll?(poll)
    if poll.in_group
      poll_in_group.map(&:id).include?(poll.id)
    else
      poll_in_public.map(&:id).include?(poll.id)
    end
  end

  private

  def poll_in_group
    Poll.without_deleted.joins(:poll_groups).where("poll_groups.group_id IN (?)", list_groups_ids)  
  end

  def poll_in_public
    Poll.without_deleted.joins(:poll_company).where("poll_companies.company_id = ?", @company.id)
  end

  def list_groups_ids
    @company.group_companies.pluck(:group_id)
  end
  
end