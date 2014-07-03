class AdminController < ApplicationController
  layout 'admin'
  
  before_filter :authenticate_admin!, :redirect_unless_admin

  def dashboard
    
  end

  def report
    @report_polls = Poll.having_status_poll(:gray, :white).where("report_count != 0")
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

  def signout
    sign_out current_admin
    redirect_to root_url
  end
end
