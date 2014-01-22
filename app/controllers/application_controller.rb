class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include AuthenSentaiHelper

  helper_method :current_member, :signed_in?, :render_to_string

  def set_current_member
    @current_member = Member.find(params[:member_id])
    unless @current_member.present?
      respond_to do |format|
        format.json { render json: Hash["response_status" => "ERROR", "response_message" => "No have this member in system."]}
      end
    end
  end

  def current_member
    begin
      @current_member ||= Member.find(session[:member_id]) if session[:member_id]
    rescue => e
      session[:member_id] = nil
    end
  end

  def signed_in?
    !current_member.nil?
  end

  def signed_user
    unless current_member.present?
      store_location
      flash[:notice] = "Please signin !"
      redirect_to authen_signin_url
    end
  end

  def current_member?(member)
    member == current_member
  end

  def is_member?
    member_id = params[:member_id]
    begin
      @find_member = Member.find(member_id)
    rescue => e
      respond_to do |wants|
        wants.json { render json: Hash["response_status" => "ERROR", "response_message" => "No have this member in system."] }
      end
    end
    @find_member
  end

  private

  def compress_gzip
    request.env['HTTP_ACCEPT_ENCODING'] = 'gzip'
  end

  def correct_member
    find_member = Member.find_by(username: params[:username])
      unless current_member?(find_member)
        respond_to do |format|
        flash[:error] = "Permission Deny"
        format.json { render json: Hash["response_status" => "ERROR", "response_message" => "No have this member in system."]}
        format.html { redirect_to root_url }
        end
      end
  end

end
