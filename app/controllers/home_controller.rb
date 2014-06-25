class HomeController < ApplicationController
  before_action :signed_user, only: [:dashboard]
  
  before_action :only_brand_account, only: [:dashboard]

  def dashboard
  end
  
  def index
    render layout: 'homepage'
  end

end
