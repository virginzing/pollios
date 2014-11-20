class MobilesController < ApplicationController
  skip_before_action :verify_authenticity_token

  expose(:member) { @auth.member }
  before_action :m_signin, only: [:polls, :vote_questionnaire]
  # before_action :set_series, only: [:polls, :vote_questionnaire]

  layout 'mobile'

  def dashboard
    
  end

  def polls
    @questionnaire = get_questionnaire_from_key(params[:key])
    @list_poll = Poll.unscoped.where("poll_series_id = ?", @questionnaire.id).order("order_poll asc")
  end

  def vote_questionnaire
    flash[:success] = "Thanks you"
    redirect_to mobile_dashboard_path
  end

  def signin
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
        flash[:notice] = "Not found"
        redirect_to mobile_dashboard_path
      end
    end
  end

  def signin_form
    
  end

  def authen
    @response = Authenticate::Sentai.signin(authen_params.merge!(Hash["app_name" => "pollios"]))
    respond_to do |wants|
      @auth = Authentication.new(@response.merge!(Hash["provider" => "sentai", "web_login" => params[:web_login]]))
      if @response["response_status"] == "OK"
        @login = true
        if authen_params[:remember_me]
          cookies.permanent[:auth_token] = member.auth_token
        else
          cookies[:auth_token] = { value: member.auth_token, expires: 6.hour.from_now }
        end
        flash[:success] = "Login Success"
        wants.js
      else
        @login = false
        flash[:warning] = "Invalid email or password."
        wants.js
      end
    end
  end

  private

  def set_series
    @questionnaire = PollSeries.find_by(qrcode_key: params[:id])

    unless @questionnaire.present?
      flash[:notice] = "Not found"
      redirect_to mobile_dashboard_path
    end
  end

  def get_questionnaire_from_key(key)
    id, series = decode64_key(key)
    @questionnaire = PollSeries.find_by(qrcode_key: id)
    raise ExceptionHandler::MobileNotFound unless @questionnaire.present?
    @questionnaire
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


end
