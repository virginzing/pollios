class FeedbackCampaignsController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :signed_user
  before_action :load_company
  before_action :check_using_service

  def index

  end

  def new
    
  end
end