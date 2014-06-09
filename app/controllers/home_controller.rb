class HomeController < ApplicationController
  before_action :signed_user, only: [:dashboard]
  
  def dashboard
    puts "#{current_admin.present?}"
  end
  
  def index
    render layout: 'homepage'
  end
end
