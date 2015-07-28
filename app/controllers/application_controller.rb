class ApplicationController < ActionController::Base

  include Authenticable
  include InitializableFeed
  include Groupable
  include ExceptionHandler
  include AuthenSentaiHelper
  include PollHelper
  include PollsHelper
  include SessionsHelper

  layout :layout_by_resource

  protect_from_forgery with: :exception

  skip_before_action :verify_authenticity_token, if: :json_request?

  decent_configuration do
    strategy DecentExposure::StrongParametersStrategy
  end

  rescue_from VersionCake::UnsupportedVersionError, :with => :render_unsupported_version

  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    render file: "/public/422", layout: false
  end

  before_filter proc { |c| c.request.path =~ /admin/ } do
    @head_stylesheet_paths = ['rails_admin_custom.css']
  end

  before_action :check_app_id, if: Proc.new { |c| c.request.format.json? && params[:member_id].present? }

  before_action :collect_passive_user, if: Proc.new { |c| c.request.format.json? && params[:member_id].present? }

  before_action :compress_gzip, if: Proc.new { |c| c.request.format.json? }

  helper_method :current_member, :signed_in?, :redirect_back_or, :redirect_back, :current_company

  def check_app_id
    app_id = request.headers["HTTP_APP_ID"]
    if app_id.present?
      fail ExceptionHandler::UnprocessableEntity, "Application expired."  unless PolliosApp.list_app_ids.include?(app_id)
    end
  end

  def collect_passive_user
    if valid_current_member.present?
      app_id = request.headers["HTTP_APP_ID"]
      MemberActiveRecord.record_member_active(valid_current_member, "passive", app_id)
    end
  end

  def collect_active_user
    if valid_current_member.present?
      app_id = request.headers["HTTP_APP_ID"]
      MemberActiveRecord.record_member_active(valid_current_member, "active", app_id)
    end
  end

  def check_using_service
    find_company ||= current_member.get_company
    if request.path.split("/")[1] == Company::FEEDBACK.downcase
      fail ExceptionHandler::WebForbidden unless find_company.using_service.include?(Company::FEEDBACK)
    else
      fail ExceptionHandler::WebForbidden unless find_company.using_service.include?(Company::SURVEY) || find_company.using_service.include?(Company::PUBLIC)
    end
  end

  def only_internal_survey
    fail ExceptionHandler::WebForbidden unless current_company.using_internal?
  end

  def only_public_survey
    fail ExceptionHandler::WebForbidden unless current_company.using_public?
  end

  def permission_deny
    respond_to do |format|
      flash[:warning] = 'Permission Deny'
      format.html { redirect_to authen_signin_path }
    end
  end

  def load_company
    @company = current_member.get_company
  end

  def only_brand_or_company_account
    return if @current_member.brand? || @current_member.company?
    cookies.delete(:auth_token)
    respond_to do |format|
      flash[:warning] = 'Only brand or companry account.'
      format.html { redirect_to authen_signin_path }
    end
  end

  def only_company_account
    return if current_member.company?
    cookies.delete(:auth_token)
    cookies.delete(:return_to)
    flash[:warning] = 'Only Company Account.'
    redirect_to users_signin_path
  end

  def current_member?(member)
    member == current_member
  end

  def only_company
    @current_member.get_company.present? if @current_member
  end

  private

  def render_unsupported_version
    headers['API-Version-Supported'] = 'false'
    respond_to do |format|
      format.json { render json: { response_message: "You requested an unsupported version (#{requested_version})"}, status: :unprocessable_entity }
    end
  end

  def compress_gzip
    request.env['HTTP_ACCEPT_ENCODING'] = 'gzip'
  end

  def redirect_unless_admin
    return if current_admin
    flash[:notice] = "You're not admin."
    redirect_to root_path
  end

  def m_signin
    return if current_member.present?
    store_location
    flash[:warning] = 'Please sign in before access this page.'
    redirect_to mobile_signin_path
  end

  def render_error(status, exception)
    respond_to do |wants|
      wants.html { render action: request.path[1..-1] }
      wants.json { render json: Hash['response_status' => status, 'response_message' => exception] }
    end
  end

  protected

  def json_request?
    request.format.json?
  end

  def layout_by_resource
    'admin' if devise_controller?
  end

  def request_http_token_authentication(realm = 'Application')
    headers['WWW-Authenticate'] = %(Token realm="#{realm.gsub(/"/, '')}")
    render json: Hash['response_status' => 'ERROR', 'response_message' => 'Access denied.'], status: :unauthorized
  end
end
