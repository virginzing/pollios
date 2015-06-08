class Company::ListCampaign
  def initialize(company)
    @company = company
  end

  def list_campaigns
    @list_campaigns ||= company_campaigns
  end

  def list_campaign_ids
    @list_campaign_ids ||= list_campaigns.pluck(:id)
  end

  def access_campaign?(campaign)
    list_campaign_ids.include?(campaign.id)
  end

  private

  def company_campaigns
    @company.campaigns
  end
  
  
end