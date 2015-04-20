class MobilesController < ApplicationController
  layout 'mobile'

  skip_before_action :verify_authenticity_token

  expose(:member) { @auth.member }
  expose(:member_decorate) { current_member.decorate }

  before_action :m_signin, only: [:polls, :vote_questionnaire, :recent_view]
  before_action :set_series, only: [:vote_questionnaire]
  before_action :set_current_member, only: [:vote_questionnaire, :vote_poll]
  before_action :set_poll, only: [:vote_poll]
  after_action :delete_cookie, only: [:authen_facebook]
  
  caches_page :terms_of_service, :privacy_policy

  before_action :compress_gzip, only: [:product_id]

  def product_id

  end
  
  def terms_of_service
    render layout: false
  end

  def privacy_policy
    render layout: false
  end

  def home

  end

  def dashboard

  end

  def check_qrcode
    render layout: false
    @key = params[:key]
  end

  def check_qrcode_member
    render layout: false
    @key = params[:key]
  end

  def recent_view
    @recent_view_questionnaire = PollSeries.joins(:history_view_questionnaires).select('poll_series.*, history_view_questionnaires.created_at as h_created_at')
                                            .where("history_view_questionnaires.member_id = ?", current_member.id).order("h_created_at desc")
    @recent_view_poll = Poll.joins(:history_views).select("polls.*, history_views.created_at as h_created_at")
                            .where("history_views.member_id = ?", current_member.id).order("h_created_at desc")
  end

  def polls
    # cookies.delete(:return_to)

    @poll, @qr_key, @series, @feedback_status = get_questionnaire_from_key(params[:key])
    # puts "qr key => #{@qr_key}"
    # puts "poll => #{@poll}"
    # puts "series => #{@series}"
    if @series == "t"

      if @feedback_status
        @questionnaire = @poll
        # raise ExceptionHandler::MobileVoteQuestionnaireAlready if HistoryVote.exists?(member_id: current_member.id, poll_series_id: @questionnaire.id)
        @history_votes = HistoryVote.exists?(member_id: current_member.id, poll_series_id: @questionnaire.id)
        
        PollSeries.view_poll(@current_member, @questionnaire) unless @history_votes

        @list_poll = Poll.unscoped.where("poll_series_id = ?", @questionnaire.id).order("polls.order_poll asc")

        @reward = CampaignMember.joins(:member).where("member_id = ? AND campaign_members.poll_series_id = ?", current_member.id, @questionnaire.id).first
        # puts "#{@reward}"
        # puts "#{@list_poll_first}"
        render 'questionnaire'
      else
        render 'close_questionnaire'
      end
    else
      @history_votes = HistoryVote.exists?(member_id: current_member.id, poll_id: @poll.id)
      Poll.view_poll(@poll, current_member) unless @history_votes
      render 'poll'
    end

    cookies.delete(:return_to)
  end

  def members
    @code, @type = get_member_from_key(params[:key])

    @special_qrcode = SpecialQrcode.find_by(code: @code)

    @member = Member.find_by(id: @special_qrcode.info["member_id"])
  end

  def vote_poll
    @poll, @history_voted = Poll.vote_poll(vote_params, current_member, params[:data_options])

    if @poll.campaign_id != 0
      if @poll.campaign.random_immediately?
        @campaign, @message = @poll.find_campaign_for_predict?(current_member, @poll)
      end
    end 

    respond_to do |wants|
      if @poll.present?
        wants.json { render json: { "msg" => "Vote Success" }, status: 200 }
      else
        wants.json { render json: { "msg" => "Vote fail" } , status: 403 }
      end
    end

  end

  def vote_questionnaire
    answer = []
    id = params[:id]
    member_id = params[:member_id]
    choice_list = params[:choices]

    params[:polls].each_with_index do |poll_id, index|
      answer << { id: poll_id, choice_id: choice_list[index] }
    end

    vote_params = {
      id: id,
      surveyed_id: member_id,
      answer: answer
    }

    @votes = @questionnaire.vote_questionnaire(vote_params, @current_member, @questionnaire)

    if @questionnaire.campaign_id != 0
      if @questionnaire.campaign.random_immediately?
        @campaign, @message = @questionnaire.find_campaign_for_predict?(@current_member, @questionnaire)
      end
    end 

    @vote_status = false

    respond_to do |wants|
      if @votes
        @vote_status = true;
        # flash[:success] = "Thanks you"
        # redirect_to mobile_dashboard_path
        wants.json { render json: { "msg" => "Vote Success" }, status: 200 }
        wants.js
      else
        # flash[:error] = "Error"
        # redirect_to mobile_dashboard_path
        wants.json { render json: { "msg" => "Vote fail" } , status: 403 }
        wants.js
      end
    end
  end


# curl -H "Content-Type: application/json" -d '{
#   "member_id": 163,
#   "answer": [{"id": 1443, "choice_id": 5216}, {"id": 1442, "choice_id": 5211}]
# }' -X POST http://localhost:3000/questionnaire/69/vote.json -i

  def signin
    raise ExceptionHandler::MobileSignInAlready if current_member

    if cookies[:return_to].nil?

    else
      url_parse = URI.parse(cookies[:return_to]).query
      # puts "url_parse => #{url_parse}"
      unless url_parse.nil?
        extract_params = CGI.parse(url_parse)
        raise ExceptionHandler::MobileForbidden unless extract_params["key"].present?

        key = extract_params["key"].first
        id, qrcode_key, series = decode64_key(key)

        # puts "id => #{id}"

        if series == "t"
          @poll = PollSeries.find_by(id: id)
          unless @poll.present?
            flash[:notice] = "Questionnaire not found"
            redirect_to mobile_dashboard_path
          end
        else
          @poll = Poll.find_by(id: id)
          unless @poll.present?
            flash[:notice] = "This poll was deleted from Pollios"
            redirect_to mobile_dashboard_path
          end
        end
      else
        cookies.delete(:return_to)
      end
    end
  end

  def signout
    cookies.delete(:auth_token)
    cookies.delete(:login)
    cookies.delete(:image)
    flash[:success] = "Logout success"
    redirect_to mobile_signin_path
  end

  def signin_form
    
  end

  def signup_form
    
  end

  def authen
    @response = Authenticate::Sentai.signin(authen_params.merge!(Hash["app_name" => "pollios"]))
    respond_to do |wants|
      @auth = Authentication.new(@response.merge!(Hash["provider" => "sentai", "web_login" => params[:web_login], "register" => :web_mobile]))
      if @response["response_status"] == "OK"
        @login = true
        if authen_params[:remember_me]
          cookies.permanent[:auth_token] = member.auth_token
        else
          cookies[:auth_token] = { value: member.auth_token, expires: 6.hour.from_now }
        end
        cookies[:login] = 'sentai'
        flash[:success] = "Login Success"
        wants.js
      else
        @login = false
        flash[:warning] = "Invalid email or password."
        wants.js
      end
    end
  end

  def authen_facebook
    env = request.env['omniauth.auth']
    @member = Member.from_omniauth(env)

    if @member.present?
      cookies.delete(:image)
      cookies[:image] = { value: env.info.image, expires: 6.hour.from_now }
      cookies[:auth_token] = { value: @member.auth_token, expires: Time.at(env.credentials.expires_at)}
      cookies[:login] = 'facebook'
      redirect_back_or mobile_dashboard_url
    else
      flash[:errors] = "Login Fail."
      redirect_to mobile_signin_path
    end
  end

  def signup_sentai
    @response = Authenticate::Sentai.signup(signup_params.merge!(Hash["app_name" => "pollios"]))
    respond_to do |wants|
      @auth = Authentication.new(@response.merge!(Hash["provider" => "sentai", "member_type" => signup_params["member_type"], "web_login" => params[:web_login], "register" => :web_mobile ]))
      if @response["response_status"] == "OK"
        @auth.member
        flash[:success] = "Signup Success"
        @signup = true
        cookies[:auth_token] = { value: member.auth_token, expires: 6.hour.from_now }
        cookies[:login] = 'sentai'

        wants.js
      else
        @signup = false
        flash[:error] = @response["response_message"]
        @flash_error = flash[:error]
        wants.html { redirect_to(:back) }
        wants.json
        wants.js
      end
    end
  end

  private

  def set_series
    @questionnaire = PollSeries.find_by(id: params[:id])

    unless @questionnaire.present?
      flash[:notice] = "Not found"
      redirect_to mobile_dashboard_path
    end
  end

  def set_poll
    @poll = Poll.find_by(id: params[:id])
    raise ExceptionHandler::NotFound, ExceptionHandler::Message::Poll::NOT_FOUND unless @poll.present?
  end

  def close_questionnaire
    render layout: false
  end

  def get_questionnaire_from_key(key)
    id, qrcode_key, series = decode64_key(key)

    if series == "t"
      @poll = PollSeries.find_by(id: id)

      if @poll.feedback
        @collection_poll_series_branch = CollectionPollSeriesBranch.where(collection_poll_series_id: @poll.collection_poll_series.id, branch_id: @poll.branch.id).order("created_at desc").first
        @poll = @collection_poll_series_branch.poll_series
        @feedback_status = @collection_poll_series_branch.collection_poll_series.feedback_status
      end
      
    else
      @poll = Poll.find_by(id: id, series: series)
    end

    raise ExceptionHandler::MobileNotFound unless @poll.present?

    [@poll, qrcode_key, series, @feedback_status]
  end

  def get_member_from_key(key)
    decode64_key_member(key)  
  end

  def decode64_key(key)
    begin
      decode64 = Base64.urlsafe_decode64(key).split("&")
      id = decode64.first.split("=").last
      qrcode_key = decode64[1].split("=").last
      series = decode64.last.split("=").last
      [id, qrcode_key, series]
    rescue => e
      cookies.delete(:return_to)
    end
  end

  def decode64_key_member(key)
    begin
      decode64 = Base64.urlsafe_decode64(key).split("&")
      code = decode64.first.split("=").last
      type = decode64.last.split("=").last
      [code, type]
    rescue => e
      cookies.delete(:return_to)
    end
  end

  def delete_cookie
    cookies.delete(:return_to)
  end

  def authen_params
    params.permit(:authen, :password, :remember_me, :web_login)
  end

  def signup_params
    params.permit(:member_type, :email, :password, :web_login)
  end

  def vote_params
    params.permit(:id, :member_id, :choice_id)
  end

end
