# use when create a new admin

class Admin::RegistrationsController < Devise::RegistrationsController

  before_filter :authenticate_admin!, :redirect_unless_admin
  skip_before_filter :require_no_authentication

  def new
    super
  end

  def create
    super
  end

  def edit
    super
  end

  def update
    super
  end

  def destroy
    super
  end

  def cancel
    super
  end

end
