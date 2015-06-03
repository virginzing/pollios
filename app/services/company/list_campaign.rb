class Company::ListCampaign
  def initialize(company)
    @company = company
  end

  def access_campaign?(campaign)
    list_campaigns_ids.include?(campaign.id)
  end

  private

  def list_campaigns_ids
    @company.campaigns.pluck(:id)
  end
  
  
end