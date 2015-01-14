class SystemSettingController < ApplicationController
  layout 'admin'

  skip_before_action :verify_authenticity_token

  before_filter :authenticate_admin!


  def index
    @maintenance_mode = Figaro.env.maintenance_mode
    @maintenance_message = Figaro.env.maintenance_message
  end

end
