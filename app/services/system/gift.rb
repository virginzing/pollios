class System::Gift
  def initialize(params, admin_id)
    @params = params
    @admin_id = admin_id
  end

  def list_member
    @params["list_member"].split(",").collect{|e| e.to_i }
  end

  def campaign
    @campaign ||= Campaign.find(@params["campaign_id"])
  end

  def create_gift_log
    GiftLog.create!(admin_id: @admin_id, campaign_id: campaign.id,  message: @params["message"], list_member: list_member)
  end
  
end