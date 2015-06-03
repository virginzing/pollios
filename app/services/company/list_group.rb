class Company::ListGroup
  def initialize(company)
    @company = company
  end

  def access_group?(group)
    list_groups.include?(group.id)
  end

  private

  def list_groups
    @company.groups.pluck(:id)
  end
  
  
end