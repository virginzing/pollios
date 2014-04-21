class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  protect_from_forgery with: :null_session

  include AuthenSentaiHelper
  include PollHelper

  decent_configuration do
    strategy DecentExposure::StrongParametersStrategy
  end

  # before_filter :if => Proc.new{ |c| c.request.path =~ /admin/ } do
  #     @head_stylesheet_paths = ['rails_admin_custom.css']
  # end

  helper_method :current_member, :signed_in?, :render_to_string
  
  def history_voted_viewed
    @history_voted  = @current_member.history_votes.includes(:choice).collect!  { |voted| [voted.poll_id, voted.choice_id, voted.choice.answer, voted.poll_series_id] }
    @history_viewed = @current_member.history_views.collect!  { |viewed| viewed.poll_id }
  end

  def history_voted_viewed_guest
    @history_voted_guest  = @current_guest.history_vote_guests.collect!  { |voted| [voted.poll_id, voted.choice_id] }
    @history_viewed_guest = @current_guest.history_view_guests.collect!  { |viewed| viewed.poll_id }
  end


  def set_current_member
    @current_member = Member.find_by(id: params[:member_id])
    unless @current_member.present?
      respond_to do |format|
        format.json { render json: Hash["response_status" => "ERROR", "response_message" => "No have this member in system."]}
      end
    end
    @current_member
  end

  def set_current_guest
    @current_guest = Guest.find_by(id: params[:guest_id])
    unless @current_guest.present?
      respond_to do |format|
        format.json { render json: Hash["response_status" => "ERROR", "response_message" => "Error."]}
      end
    end
  end

  def restrict_access  
    authenticate_or_request_with_http_token do |token, options|
      access_token = set_current_member.providers.where("token = ?", token)
      unless access_token.present?
        respond_to do |format|
          format.json { render json: Hash["response_status" => "ERROR", "response_message" => "Access denied"]}
        end
      else
        true
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

  def redirect_unless_admin
    unless current_admin
      flash[:notice] = "Only Admin"
      redirect_to root_path
    end
  end

end
