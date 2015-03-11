class GiftsController < ApplicationController
  layout 'admin'
  skip_before_action :verify_authenticity_token

  before_filter :authenticate_admin!

  def index
    
  end


end
