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

  # before_filter :test_maintenance

  before_filter :if => Proc.new{ |c| c.request.path =~ /admin/ } do
    @head_stylesheet_paths = ['rails_admin_custom.css']
  end
  # before_filter :check_maintenance

  before_filter :check_token, :if => Proc.new { |c| c.request.format.json? }

  helper_method :current_member, :signed_in?, :render_to_string, :only_company, :redirect_back_or, :redirect_back

  def check_token
    token = request.headers['Authorization']
    # puts "token => #{token}"
    if params[:member_id] && token.present?
      authenticate_or_request_with_http_token do |token, options|
        access_token = set_current_member.api_tokens.where("token = ?", token)
        unless access_token.present?
          raise ExceptionHandler::Unauthorized, ExceptionHandler::Message::Token::WRONG
        else
          true
        end
      end
    end
    
  end

  def test_maintenance
    render '/public/503.html', :layout => false, status: 503
  end

  def check_maintenance
    maintenance_mode = Figaro.env.maintenance_mode

    if maintenance_mode == "true"
      respond_to do |wants|
        wants.html { }
        wants.json { raise ExceptionHandler::Maintenance, ExceptionHandler::Message::Maintenance::OPEN }
      end
    end
  end

  def check_using_service
    if controller_name == "companies" || controller_name == "company_campaigns"
      check_service = 'Survey'
    else
      check_service = 'Feedback'
    end

    unless current_member.get_company.using_service.include?(check_service)
      respond_to do |format|
        flash[:warning] = 'Permission Deny'
        format.html { redirect_to authen_signin_path }
      end
    end
  end

  def load_company
    @company = current_member.get_company
  end

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
    init_list_group = Member::ListGroup.new(@current_member)
    your_group = init_list_group.active

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
    @current_member = Member.cached_find(params[:member_id])
  
    raise ExceptionHandler::Forbidden, ExceptionHandler::Message::Member::BLACKLIST if @current_member.blacklist?
    raise ExceptionHandler::Forbidden, ExceptionHandler::Message::Member::BAN if @current_member.ban?

    Member.current_member = @current_member
    @current_member
  end

  def set_current_guest
    @current_guest = Guest.find_by(id: params[:guest_id])
    unless @current_guest.present?
      respond_to do |format|
        format.json { render json: Hash["response_status" => "ERROR", "response_message" => "Error."] }
      end
    end
  end

  def restrict_access
    authenticate_or_request_with_http_token do |token, options|
      access_token = set_current_member.providers.where("token = ?", token)
      unless access_token.present?

      else
        true
      end
    end
  end

  def restrict_only_admin
    if current_member
      unless current_member.brand?
        reset_session
        flash[:warning] = "Only Brand Account."
        redirect_to authen_signin_path
      end
    end
  end

  def only_company_account
    if current_member
      unless current_member.company?
        cookies.delete(:auth_token)
        cookies.delete(:return_to)
        flash[:warning] = "Only Company Account"
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
    @current_member.get_company.present? if @current_member
  end

  private

  # Member.current_member = Member.find(85)

  def load_resource_poll_feed
    if params[:member_id]

      init_list_friend = Member::ListFriend.new(Member.current_member)
      init_list_poll = Member::ListPoll.new(Member.current_member)
      init_list_group = Member::ListGroup.new(Member.current_member)

      Member.list_friend_active = init_list_friend.active
      Member.list_friend_block = init_list_friend.block
      Member.list_friend_request = init_list_friend.friend_request
      Member.list_your_request = init_list_friend.your_request
      Member.list_friend_following = init_list_friend.following

      Member.list_group_active = init_list_group.active
      Member.reported_polls = init_list_poll.reports
      Member.viewed_polls   = init_list_poll.history_viewed
      Member.voted_polls    = init_list_poll.voted_all
      Member.watched_polls  = init_list_poll.watched_poll_ids
      # p "=== End ==="
    end
  end

  def compress_gzip
    request.env['HTTP_ACCEPT_ENCODING'] = 'gzip'
  end

  def request_json?
    request.format.json?
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

  def render_error(status, exception)
    respond_to do |wants|
      wants.html { render action: request.path[1..-1] }
      wants.json { render json: Hash["response_status" => status, "response_message" => exception] }
    end
  end

  protected

  def layout_by_resource
    if devise_controller?
      "admin"
    end
  end

  protected

  def request_http_token_authentication(realm = "Application")
    self.headers["WWW-Authenticate"] = %(Token realm="#{realm.gsub(/"/, "")}")
    render json: Hash["response_status" => "ERROR", "response_message" => "Access denied"], :status => :unauthorized
  end

end
