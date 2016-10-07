module V1::Auth
  class PostController < V1::ApplicationController
    skip_before_action :verify_authenticity_token

    before_action :set_web_app_authentication

    before_action :must_not_signed_in, only: [:sign_in]

    def sign_in
      member = @web_app_authentication.sign_in(params[:email], params[:password])
      return handle_sign_in_failed if @web_app_authentication.sign_in_failed?

      save_member_session(member)

      redirect_to :back
    end

    private

    def handle_sign_in_failed
      flash[:type] = 'error'
      flash[:message] = 'E-mail or password incorrect.'

      redirect_to :back
    end

    def must_not_signed_in
    end

    def set_web_app_authentication
      @web_app_authentication ||= WebApp::Authentication.new
    end

    def save_member_session(member)
      session[:member_id] = member.id
    end
  end
end
