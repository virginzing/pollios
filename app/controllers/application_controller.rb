class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  
  # before_action :restrict_only_admin
  layout :layout_by_resource

  include ExceptionHandler
  include AuthenSentaiHelper
  include PollHelper
  include PollsHelper

  decent_configuration do
    strategy DecentExposure::StrongParametersStrategy
  end

  before_filter :if => Proc.new{ |c| c.request.path =~ /admin/ } do
    @head_stylesheet_paths = ['rails_admin_custom.css']
  end

  helper_method :current_member, :signed_in?, :render_to_string, :only_company, :redirect_back_or, :redirect_back

  def history_voted_viewed
    # @history_voted  = @current_member.history_votes.includes(:choice).collect!  { |voted| [voted.poll_id, voted.choice_id, voted.choice.answer, voted.poll_series_id, voted.choice.vote] }
    @history_voted = HistoryVote.joins(:member, :choice, :poll)
    .select("history_votes.*, choices.answer as choice_answer, choices.vote as choice_vote, polls.show_result as display_result")
    .where("history_votes.member_id = #{@current_member.id}")
    .collect! { |voted| [voted.poll_id, voted.choice_id, voted.choice_answer, voted.poll_series_id, voted.choice_vote, voted.display_result] }
    @history_viewed = @current_member.history_views.collect!  { |viewed| viewed.poll_id }
  end

  def history_voted_viewed_guest
    @history_voted_guest  = @current_guest.history_vote_guests.collect!  { |voted| [voted.poll_id, voted.choice_id] }
    @history_viewed_guest = @current_guest.history_view_guests.collect!  { |viewed| viewed.poll_id }
  end

  def get_your_group
    your_group = @current_member.cached_get_group_active
    @group_by_name = Hash[your_group.map{ |f| [f.id, Hash["id" => f.id, "name" => f.name, "photo" => f.get_photo_group, "member_count" => f.member_count, "poll_count" => f.poll_count]] }]
  end

  def only_brand_or_company_account
    unless @current_member.brand? || @current_member.company?
      cookies.delete(:auth_token)
      respond_to do |format|
        flash[:warning] = 'Only brand or companry account.'
        format.html { redirect_to authen_signin_path }
      end
    end
  end

  def set_current_member
    @current_member = Member.find_by(id: params[:member_id])
    unless @current_member.present?
      respond_to do |format|
        format.json { render json: Hash["response_status" => "ERROR", "response_message" => "No have this member in system."]}
        format.html
      end
    else
      if @current_member.blacklist?
        respond_to do |format|
          format.json { render json: Hash["response_status" => "ERROR", "response_message" => "This account is blacklist."]}
        end
      end
    end
    Member.current_member = @current_member
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

  def restrict_only_admin
    if current_member
      unless current_member.brand?
        reset_session
        flash[:notice] = "Only Brand Account."
        redirect_to authen_signin_path
      end
    end
  end

  def only_company_account
    if current_member
      unless current_member.company?
        cookies.delete(:auth_token)
        flash[:notice] = "Only Company Account"
        redirect_to users_signin_path
      end
    end
  end

  # def current_member
  #   begin
  #     @current_member ||= Member.find(session[:member_id]) if session[:member_id]
  #   rescue => e
  #     session[:member_id] = nil
  #   end
  # end

  def current_member
    @current_member ||= Member.find_by(auth_token: cookies[:auth_token]) if cookies[:auth_token]
  end

  def signed_in?
    !current_member.nil?
  end

  def signed_user
    unless current_member.present?
      store_location
      flash[:warning] = "Please sign in before access this page."
      redirect_to users_signin_url
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

  def only_company
    @current_member.company? if @current_member
  end

  private

  # Member.current_member = Member.find(85)

  def load_resource_poll_feed
    if params[:member_id] && request.format.json?
      p "=== Load Resource Poll Feed ==="
      # Member.current_member = Member.find(93)
      Member.list_friend_block      = Member.current_member.cached_block_friend
      Member.list_friend_active     = Member.current_member.cached_get_friend_active
      Member.list_friend_request    = Member.current_member.cached_get_friend_request
      Member.list_friend_following  = Member.current_member.cached_get_following
      Member.list_your_request      = Member.current_member.cached_get_your_request
      Member.list_group_active      = Member.current_member.cached_get_group_active

      Member.reported_polls = Member.current_member.cached_report_poll
      Member.shared_polls   = Member.current_member.cached_shared_poll
      Member.viewed_polls   = Member.current_member.get_history_viewed
      Member.voted_polls    = Member.current_member.cached_my_voted_all
      Member.watched_polls  = Member.current_member.cached_watched
      p "=== End ==="
    end
  end

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

  def m_signin
    unless current_member.present?
      store_location
      flash[:warning] = "Please sign in before access this page."
      redirect_to mobile_signin_path
    end
  end

  protected

  def layout_by_resource
    if devise_controller?
      "admin"
    end
  end

end
