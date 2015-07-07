class AdminController < ApplicationController
  layout 'admin'
  skip_before_action :verify_authenticity_token, only: [:login_as, :create_notification]

  before_filter :authenticate_admin!, :redirect_unless_admin, except: [:load_reason_poll, :load_reason_member]

  def dashboard

  end

  def notification
    
  end

  def create_notification
    @init_notification = Notify::PushNotification.new(notification_params)

    if @init_notification.send
      flash[:success] = "Send notification successfully"
      redirect_to admin_notification_path
    else
      flash[:error] = "Something's went wrong"
      render 'notification'
    end
  end

  def report
    @report_polls = Admin::ReportPoll.new.get_report_poll
    @report_members = Member.with_status_account(:normal).where("report_count != 0")
  end

  def load_reason_poll
    @load_reason = MemberReportPoll.where("poll_id = ? AND message != ''", params[:poll_id])
    puts "#{@load_reason.count}"
    render layout: false
  end

  def load_reason_member
    @load_reason = MemberReportMember.where("reportee_id = ? AND message != ''", params[:friend_id])
    puts "#{@load_reason.count}"
    render layout: false
  end

  def invite
    @invite_codes = InviteCode.joins(:company).select("invite_codes.*, companies.name as company_name")
  end

  def certification
    @certificate = Apn::App.first
  end

  def edit_ceritification
   
  end

  def update_certification
     @certificate = Apn::App.find(params[:id])
     
     @certificate.apn_dev_cert = File.read(cert_params[:apn_dev_cert].path) if cert_params[:apn_dev_cert]
     @certificate.apn_prod_cert = File.read(cert_params[:apn_prod_cert].path) if cert_params[:apn_prod_cert]

     if @certificate.save
      flash[:success] = "Update Success"
      redirect_to admin_certification_path
     else
      flash[:error] = "Error"
      render 'edit_ceritification'
     end
  end

  def login_as
    begin
      member = Member.find_by(email: login_as_params[:email])
      cookies[:auth_token] = { value: member.auth_token, expires: 6.hour.from_now }
      flash[:success] = "Login success as #{member.email}"

      @company = member.get_company.decorate

      @feedback = @company.using_service? Company::FEEDBACK
      @internal_survey = @company.using_service? Company::SURVEY
      @public_survey = @company.using_service? Company::PUBLIC

      if @feedback || @internal_survey || @public_survey
        redirect_to select_services_path
      else
        flash[:error] = "Permission denied."
        redirect_to authen_sentai_path
      end
    rescue => e
      flash[:error] = "Error"
      redirect_to commercials_path
    end
  end

  def signout
    sign_out current_admin
    redirect_to root_url
  end

  private

  def login_as_params
    params.permit(:email)
  end

  def cert_params
    params.require(:apn_app).permit(:apn_prod_cert, :apn_dev_cert)
  end

  def notification_params
    params.permit(:env, :device_token, :alert, :sound, :badge)
  end

end
