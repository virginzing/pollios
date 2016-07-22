module V1
  class AdminController < V1::ApplicationController
    before_filter :authenticate_admin!
    rescue_from ActionController::InvalidAuthenticityToken, with: :invalid_signin_credential
  end
end
