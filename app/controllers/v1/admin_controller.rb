module V1
  class AdminController < V1::ApplicationController
    before_action :authenticate_v1_admin!
    rescue_from ActionController::InvalidAuthenticityToken, with: :invalid_signin_credential
    helper V1::MenuHelper

  end
end
