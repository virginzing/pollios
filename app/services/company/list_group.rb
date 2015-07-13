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

  def public_group
    all.select{ |g| g.public }
  end

  def show_in_groups
    if @company.using_public? && @company.using_internal?
      all
    elsif @company.using_internal? 
      exclusive
    else
      public_group
    end
  end

  private

  def list_group_ids
    list_groups.pluck(:id)
  end

  def list_groups
    @company.groups.order("name asc").without_deleted
  end

end
