module V1::Auth
  class PostController < V1::ApplicationController
    before_action :must_not_signed_in, only: [:sign_in, :sign_up]
    before_action :set_web_app_authentication

    def sign_in
      member = @web_app_authentication.sign_in(params[:email], params[:password])
      return handle_sign_in_failed if @web_app_authentication.failed?

      save_member_session(member)

      redirect_to :back
    end

    def sign_up
      member = @web_app_authentication.sign_up(params[:email], params[:password])
      return handle_sign_up_failed if @web_app_authentication.failed?

      save_member_session(member)

      return redirect_to params[:redirect_path] if params[:redirect_path].present?
      redirect_to root_path
    end

    private

    def handle_sign_in_failed
      flash[:type] = 'error'
      flash[:message] = 'E-mail or password incorrect.'

      redirect_to :back
    end

    def handle_sign_up_failed
      flash[:type] = 'error'
      flash[:message] = @web_app_authentication.error_message

      redirect_to :back
    end

    def must_not_signed_in
      redirect_to root_path unless :back.present?
      redirect_to :back if member_signed_in?
    end

    def set_web_app_authentication
      @web_app_authentication ||= WebApp::Authentication.new
    end

    def save_member_session(member)
      session[:member_id] ||= member.id
    end
  end
end
