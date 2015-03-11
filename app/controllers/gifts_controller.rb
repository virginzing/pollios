class GiftsController < ApplicationController
  layout 'admin'
  skip_before_action :verify_authenticity_token

  before_filter :authenticate_admin!

  def index
    
  end

  def new
    @campaigns = Company.where(company_admin: true).first.campaigns
    @gift = CampaignMember.new
  end

  def create
    
  end



end
