class Company::ListGroup
  def initialize(company)
    @company = company
  end

  def access_group?(group)
    list_group_ids.include?(group.id)
  end

  def all
    @all ||= list_groups
  end

  def exclusive
    all.select{ |g| g.company? }
  end

  def public
    all.select{ |g| g.public }
  end

  private

  def list_group_ids
    list_groups.pluck(:id)
  end

  def list_groups
    @company.groups.order("name asc").without_deleted
  end
  
  
end