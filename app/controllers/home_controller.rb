class HomeController < ApplicationController
  before_action :signed_user, only: [:dashboard]
  
  def dashboard

  end
  
  def index
    render layout: 'homepage'
  end
end
