class FeedbackController < ApplicationController

  before_action :signed_user
  before_action :load_company
  before_action :check_using_service

  def dashboard

  end

  def setting

  end

end
