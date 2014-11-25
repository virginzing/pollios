class MobilesController < ApplicationController
  layout 'mobile'

  skip_before_action :verify_authenticity_token

  expose(:member) { @auth.member }
  expose(:member_decorate) { current_member.decorate }
  # expose(:image) { cookies[:login] == 'facebook' ? cookies[:image] : member_decorate. }

  before_action :m_signin, only: [:polls, :vote_questionnaire, :recent_view]
  before_action :set_series, only: [:vote_questionnaire]
  before_action :set_current_member, only: [:vote_questionnaire]

  def home
    
  end

  def dashboard

  end

  def recent_view
    @recent_view = PollSeries.joins(:history_view_questionnaires).where("history_view_questionnaires.member_id = ?", current_member.id).uniq.limit(10)
  end

  def polls
    @poll, @series = get_questionnaire_from_key(params[:key])
    if @series == "t"
      @questionnaire = @poll

      # raise ExceptionHandler::MobileVoteQuestionnaireAlready if HistoryVote.exists?(member_id: current_member.id, poll_series_id: @questionnaire.id)
      @history_votes = HistoryVote.exists?(member_id: current_member.id, poll_series_id: @questionnaire.id)
      
      PollSeries.view_poll(@current_member, @questionnaire) unless @history_votes

      @list_poll = Poll.unscoped.where("poll_series_id = ?", @questionnaire.id).order("order_poll asc")
      render 'questionnaire'
    else
      render 'poll'
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
      member_id: member_id,
      answer: answer
    }

    @votes = @questionnaire.vote_questionnaire(vote_params, @current_member, @questionnaire)
    # sleep 2
    
    @vote_status = false

    respond_to do |wants|
      if true
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
      puts "url_parse => #{url_parse}"
      unless url_parse.nil?
        extract_params = CGI.parse(url_parse)
        raise ExceptionHandler::MobileForbidden unless extract_params["key"].present?

        key = extract_params["key"].first
        id, series = decode64_key(key)
        @questionnaire = PollSeries.find_by(qrcode_key: id)

        unless @questionnaire.present?
          flash[:notice] = "Not found"
          redirect_to mobile_dashboard_path
        end
      else
        cookies.delete(:return_to)
        flash[:notice] = "Sign in before."
        redirect_to mobile_signin_path
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
      cookies[:image] = { value: env.info.image, expires: Time.at(env.credentials.expires_at)}
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

  def get_questionnaire_from_key(key)
    id, series = decode64_key(key)

    if series == "t"
      @poll = PollSeries.find_by(qrcode_key: id)
    else
      @poll = Poll.find_by(qrcode_key: id, series: series)
    end

    raise ExceptionHandler::MobileNotFound unless @poll.present?

    [@poll, series]
  end

  def decode64_key(key)
    begin
      decode64 = Base64.urlsafe_decode64(key).split("&")
      id = decode64.first.split("=").last
      series = decode64.last.split("=").last
      [id, series]
    rescue => e
      cookies.delete(:return_to)
    end
  end

  def authen_params
    params.permit(:authen, :password, :remember_me, :web_login)
  end

  def signup_params
    params.permit(:member_type, :email, :password, :web_login)
  end

end
