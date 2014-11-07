class AdminController < ApplicationController
  layout 'admin'
  skip_before_action :verify_authenticity_token, only: [:login_as]

  before_filter :authenticate_admin!, :redirect_unless_admin, except: [:load_reason_poll, :load_reason_member]

  def dashboard

  end

  def report
    @report_polls = Admin::ReportPoll.new.get_report_poll
    @report_members = Member.having_status_account(:normal).where("report_count != 0")
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
  end

  def login_as
    begin
      member = Member.find_by(email: login_as_params[:email])
      cookies[:auth_token] = { value: member.auth_token, expires: 6.hour.from_now }
      flash[:success] = "Login success as #{member.email}"
      redirect_to dashboard_path
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

end
