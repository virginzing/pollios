class Company::ListMember

  def initialize(company)
    @company = company
  end

  def get_list_members
    @get_list_members ||= company_members
  end


  private

  def company_members
    @company_members = Member.joins(:company_member).includes(:groups).where("company_members.company_id = ?", @company.id).uniq.references(:groups)
  end
  
  
end