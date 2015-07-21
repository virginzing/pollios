class SystemSettingController < ApplicationController
  layout 'admin'

  before_filter :authenticate_admin!

  def index
    @maintenance_mode = Figaro.env.maintenance_mode
    @maintenance_message = Figaro.env.maintenance_message
  end

end
