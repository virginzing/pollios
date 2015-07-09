# ApplicationController
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  layout :layout_by_resource
  include ExceptionHandler
  include AuthenSentaiHelper
  include PollHelper
  include PollsHelper

  decent_configuration do
    strategy DecentExposure::StrongParametersStrategy
  end

  before_filter proc { |c| c.request.path =~ /admin/ } do
    @head_stylesheet_paths = ['rails_admin_custom.css']
  end

  before_filter :check_token, proc { |c| c.request.format.json? }

  helper_method :current_member, :signed_in?, :redirect_back_or, :redirect_back

  def check_token
    token_from_header = request.headers['Authorization']
    return unless params[:member_id] && token_from_header.present?
    authenticate_or_request_with_http_token do |token, _options|
      access_token = set_current_member.api_tokens.where('token = ?', token)
      fail ExceptionHandler::Unauthorized, ExceptionHandler::Message::Token::WRONG unless access_token.present?
      true
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

  def permission_deny
    respond_to do |format|
      flash[:warning] = 'Permission Deny'
      format.html { redirect_to authen_signin_path }
    end
  end

  def load_company
    @company = current_member.get_company
  end

  def history_voted_viewed
    @history_voted = HistoryVote.joins(:member, :choice, :poll) \
                                .select('history_votes.*, choices.answer as choice_answer, choices.vote as choice_vote, polls.show_result as display_result') \
                                .where("history_votes.member_id = #{@current_member.id}") \
                                .collect! { |voted| [voted.poll_id, voted.choice_id, voted.choice_answer, voted.poll_series_id, voted.choice_vote, voted.display_result] }
    @history_viewed = @current_member.history_views.map(&:poll_id)
  end

  def get_your_group
    init_list_group = Member::ListGroup.new(@current_member)
    your_group = init_list_group.active

    @group_by_name = Hash[your_group.map { |f| [f.id, Hash['id' => f.id, 'name' => f.name, 'photo' => f.get_photo_group, 'member_count' => f.member_count, 'poll_count' => f.poll_count]] }]
  end

  def only_brand_or_company_account
    return if @current_member.brand? || @current_member.company?
    cookies.delete(:auth_token)
    respond_to do |format|
      flash[:warning] = 'Only brand or companry account.'
      format.html { redirect_to authen_signin_path }
    end
  end

  def set_current_member
    @current_member = Member.cached_find(params[:member_id])
    fail ExceptionHandler::Forbidden, ExceptionHandler::Message::Member::BLACKLIST if @current_member.blacklist?
    fail ExceptionHandler::Forbidden, ExceptionHandler::Message::Member::BAN if @current_member.ban?
    Member.current_member = @current_member
    @current_member
  end

  def only_company_account
    return if current_member.company?
    cookies.delete(:auth_token)
    cookies.delete(:return_to)
    flash[:warning] = 'Only Company Account.'
    redirect_to users_signin_path
  end

  def current_member
    @current_member ||= Member.find_by(auth_token: cookies[:auth_token]) if cookies[:auth_token]
  end

  def signed_in?
    !current_member.nil?
  end

  def signed_user
    return if current_member.present?
    store_location
    flash[:warning] = 'Please sign in before access this page.'
    redirect_to users_signin_url
  end

  def current_member?(member)
    member == current_member
  end

  def only_company
    @current_member.get_company.present? if @current_member
  end

  private

  def load_resource_poll_feed
    return unless params[:member_id]
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
  end

  def compress_gzip
    request.env['HTTP_ACCEPT_ENCODING'] = 'gzip'
  end

  def request_json?
    request.format.json?
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

  def layout_by_resource
    'admin' if devise_controller?
  end

  protected

  def request_http_token_authentication(realm = 'Application')
    headers['WWW-Authenticate'] = %(Token realm="#{realm.gsub(/"/, '')}")
    render json: Hash['response_status' => 'ERROR', 'response_message' => 'Access denied.'], status: :unauthorized
  end
end
