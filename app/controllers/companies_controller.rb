class CompaniesController < ApplicationController

  decorates_assigned :poll, :member

  before_action :signed_user
  before_action :set_company
  before_action :check_using_service
  before_action :find_group
  before_action :set_poll, only: [:poll_detail, :delete_poll, :group_poll_detail, :edit_poll]
  before_action :set_group, only: [:remove_surveyor, :list_polls_in_group, :list_members_in_group, :destroy_group, :group_detail, :update_group, :group_poll_detail, :edit_group]
  before_action :set_member, only: [:member_detail]
  before_action :only_internal_survey

  expose(:group_company) { current_member.get_company.groups if current_member }
  expose(:group_id) { @group }
  expose(:group) { @group.decorate }
  expose(:exclusive_groups) { Company::ListGroup.new(current_company).exclusive }

  def dashboard
    @init_poll ||= PollOfGroup.new(current_member, exclusive_groups, options_params)
    @poll_latest_list = @init_poll.get_poll_of_group_company.except_series.limit(5)
    @poll_latest_in_public = Company::PollPublic.new(current_company).get_list_public_poll
    render 'home/dashboard_company'
  end

  def new
    @invite = InviteCode.new
  end

  def invites
    @invite_codes = InviteCode.joins(:company).includes(:group, :member_invite_code => :member)
                              .select("invite_codes.*, companies.name as company_name")
                              .where("invite_codes.company_id = ?", @find_company.id)
                              .order("invite_codes.id desc")
    @invite = InviteCode.new
    @groups = Company::ListGroup.new(@find_company).exclusive
  end

  def search
    @search = Poll.includes(:choices, :member).select('polls.*').joins(:groups)
                  .where("poll_groups.group_id IN (?)", current_member.get_company.groups.map(&:id)).uniq
                  .where("polls.title LIKE (?)", "%#{params[:q]}%")
                  .order("polls.created_at DESC")
                  .paginate(page: params[:page], per_page: 10).decorate
  end


  def poll_flags
    @report_polls = Company::CompanyReportPoll.new(company_groups, @find_company).get_report_only_exclusive_groups
  end

  def via_email
    @via_email = InviteCode.new
    @groups = Company::ListGroup.new(@find_company).all
  end

  def send_email
    begin

    list_email_text = invite_code_params[:list_email].split("\r\n")
    list_email_file = []
    file = invite_code_params[:file]
    group_id = invite_code_params[:group_id]

    if file.present?
      if File.extname(file.original_filename) == ".txt"
        File.readlines(file.path).each do |line|
          list_email_file << line.strip
        end
      else
        spreadsheet = Company.open_spreadsheet(file)
        header = spreadsheet.row(1)
        (2..spreadsheet.last_row).each do |i|
          list_email_file << spreadsheet.row(i).first
        end
      end
    end

    total_email = ( list_email_text | list_email_file.collect.to_a).collect{|e| e.downcase }.uniq

    respond_to do |format|
      @send_email = SendInvitesWorker.perform_async(total_email, group_id.to_i, @find_company.id )

      if @send_email
        flash[:success] = "Send invite code via email successfully."
        format.html { redirect_to company_invites_path }
      else
        flash[:error] = "Error"
        format.html { redirect_to via_email_path }
      end
    end
    rescue => e
      flash[:error] = "Something went wrong"
      redirect_to via_email_path
    end
  end

  def generate_invitation
    respond_to do |format|
      if @find_company.generate_invitation_of_group(company_params)
        flash[:success] = "Create invite code successfully."
        format.html { redirect_to company_invites_path }
      else
        flash[:error] = "Something went wrong."
        format.html { redirect_to company_invites_path }
      end
    end
  end

  def new_member
    @multi_signup = Member.new
  end

  def multi_signup_via_company
    @nothing = false
    @multi_signup = Member.new

    list_email = multi_signup_params[:list_email]
    file = multi_signup_params[:file]

    if list_email.present? && file.present?

      list_email_text = multi_signup_params[:list_email].split("\r\n")

      list_email_file = []

      if file.present?
        if File.extname(file.original_filename) == ".txt"
          File.readlines(file.path).each do |line|
            list_email_file << line.strip
          end
        else
          spreadsheet = Company.open_spreadsheet(file)
          header = spreadsheet.row(1)
          (2..spreadsheet.last_row).each do |i|
            list_email_file << spreadsheet.row(i).first
          end
        end
      end

      total_email = ( list_email_text | list_email_file).collect{|e| e.downcase }.uniq

      new_multi_signup_params = {
        "list_email" => total_email,
        "password" => multi_signup_params[:password]
      }

      @response = Authenticate::Sentai.multi_signup(new_multi_signup_params.merge!(Hash["app_name" => "pollios"]))

      email_signup_error = @response["signup_error"]
      email_signup_success = @response["signup_success"]

      email_signup_success.each do |email|
        @response = {
          "email" => email
        }
        @auth = Authentication.new(@response.merge!(Hash["provider" => "sentai", "member_type" => "0", "company_id" => multi_signup_params[:company_id], "register" => :in_app ]))
        @auth.member
      end

    else
      @nothing = true
    end

    respond_to do |wants|

      if @nothing
        flash[:notice] = "Plese fill <u>list email</u> or <u>import file</u> such as excel, csv, txt"
        wants.html { redirect_to new_member_to_company_path }
      else
        if email_signup_success.size > 0
          flash[:success] = "Email: #{email_signup_success} created sucessfully"
          wants.html { render 'new_member' }
        else
          flash[:error] = "Email: #{email_signup_error} have already taken"
          wants.html { render 'new_member' }
        end
      end
    end
  end

  def remove_member
    # @group = Member.find(params[:member_id]).cancel_or_leave_group(params[:group_id], "L")
    @group = Group.leave_group(Member.cached_find(params[:member_id]), Group.cached_find(params[:group_id]))

    respond_to do |format|
      if @group
        flash[:success] = "Remove successfully."
        format.html { redirect_to company_group_detail_path(params[:group_id]) }
      else
        flash[:error] = "Error"
        format.html { render 'list_members' }
      end
    end
  end

  def list_polls  ## company polls
    @init_poll = PollOfGroup.new(current_member, exclusive_groups, options_params, true)
    @polls = @init_poll.get_poll_of_group_company.decorate
  end

  def list_questionnaires
    @list_questionnaires = Company::ListPollSeries.new(set_company).only_internal_survey
  end

  def list_campaigns
    @list_campaigns = Company::ListCampaign.new(set_company).list_campaigns.decorate
  end

  def setting

  end

  #TODO: Make a proper service model for Group::PollList with Company::GroupList
  def poll_detail
    @member = @poll.member
    @poll = @poll.decorate
    @choice_data_chart = []
    @poll_data = []

    @choice_poll = @poll.cached_choices.collect{|e| [e.answer, e.vote] }
    @choice_poll_latest_max = @choice_poll.collect{|e| e.last }.max

    @choice_poll.each do |choice|
      @poll_data << { "name" => choice.first, "value" => choice.last }
    end

    if current_member.get_company.present?
      init_company = PollDetailCompany.new(@poll.groups, @poll)
      @member_group = init_company.get_member_in_group
      @member_voted_poll = init_company.get_member_voted_poll
      @member_novoted_poll = init_company.get_member_not_voted_poll
      @member_viewed_poll = init_company.get_member_viewed_poll
      @member_noviewed_poll = init_company.get_member_not_viewed_poll
      @member_viewed_no_vote_poll = init_company.get_member_viewed_not_vote_poll

      @qr = RQRCode::QRCode.new(GenerateQrcodeLink.new(@poll).get_redirect_link, :size => 8, :level => :h ).to_img.resize(200, 200).to_data_url
      # puts "qr => #{GenerateQrcodeLink.new(@poll).get_redirect_link}"
      if @member_group.size > 0
        @percent_vote = ((@member_voted_poll.size * 100)/@member_group.size).to_s
        @percent_novote = ((@member_novoted_poll.size * 100)/@member_group.size).to_s
        @percent_view = ((@member_viewed_poll.size * 100)/@member_group.size).to_s
        @percent_noview = ((@member_noviewed_poll.size * 100)/@member_group.size).to_s
      else
        zero_percent = "0"
        @percent_vote = zero_percent
        @percent_novote = zero_percent
        @percent_view = zero_percent
        @percent_noview = zero_percent
      end
    end
  end

  def edit_poll
    @groups = Group.eager_load(:group_company, :poll_groups, :group_members).where("group_companies.company_id = #{set_company.id}").uniq
  end

  def update_poll
    @poll = Poll.find(params[:id])

    if update_poll_params[:expire_status].to_b
      @poll.expire_date = Time.zone.now
    end

    if update_poll_params[:remove_campaign].to_b
      @poll.campaign_id = 0
    end

    if @poll.update(update_poll_params)
      flash[:success] = "Successfully updated..."
      redirect_to company_poll_detail_path
    else
      flash[:error] = "Something weng wrong"
      redirect_to company_edit_poll_path(@poll)
    end
  end

  ### Group ###

  def list_group
    @member = Member.cached_find(params[:member_id])
    init_list_group = Member::GroupList.new(@member)

    @company = Company.find(params[:company_id])
    @member_group_active = init_list_group.active.map(&:id)
    @member_group_inactive = init_list_group.inactive.map(&:id)

    @list_groups = Company::GroupList.new(@company).all
    render layout: false
  end

  def company_groups
    @groups = exclusive_groups
  end

  def list_polls_in_group
    @init_poll = PollOfGroup.new(current_member, @group, options_params)
    @polls = @init_poll.get_poll_of_group
  end

  def list_members_in_group
    @members = Member.joins(:group_members).select("members.*, group_members.created_at as joined_at, group_members.is_master as admin")
                      .where("group_members.group_id = ? AND group_members.active = 't'", @group) || []
  end

  def member_detail
    member_with_group = @member.get_group_active.with_group_type(:company)

    @init_poll = PollOfGroup.new(current_member,member_with_group, options_params, true)

    list_voted_poll_ids = @member.cached_my_voted_all.collect{ |e| e[:poll_id] }

    if member_with_group.present?
      query = @init_poll.get_poll_of_group_company
      query = query.where("polls.id NOT IN (?)", list_voted_poll_ids) if list_voted_poll_ids.size > 0
      @list_unvote_poll = query.decorate
    else
      @list_unvote_poll = []
    end

  end

  def new_group
    @group = Group.new
    @members = Company::ListMember.new(current_member.get_company).get_list_members
  end

  def new_add_surveyor
    @groups = exclusive_groups
    @list_members_in_company = Company::ListMember.new(set_company).get_list_members
    @add_surveyor = Company.new
  end

  def add_surveyor
    GroupSurveyor.transaction do
      begin
        member_id = params[:company][:member_id]
        find_member = Member.find(member_id)
        group_id = params[:group_id]

        list_group = Group.where(id: group_id)

        list_group.each do |group|
          find_member.add_role :surveyor, group
          find_member.create_group_surveyor(group.id)
        end
        flash[:success] = "Add surveyor successfully"
        redirect_to company_members_path
      end
    end

  end

  def remove_surveyor
    group_id = params[:group_id]
    member_id = params[:surveyor_id]
    find_group = Group.find(group_id)
    find_member = Member.find(member_id)

    remove_surveyor = find_member.remove_role :surveyor, find_group

    if remove_surveyor.present?
      find_member.remove_group_surveyor(group_id)
      flash[:success] = "Remove surveyor successfully."
      redirect_to company_group_detail_path(find_group)
    end
  end

  def group_detail
    fail ExceptionHandler::Forbidden unless Company::ListGroup.new(current_member.get_company).access_group?(@group)

    init_poll = Company::Groups::ListPolls.new(@group)
    @polls = init_poll.all

    @member_all = Group::MemberList.new(@group)

    @members = @member_all.active
    @members_inactive = @member_all.pending

    @list_surveyor = @group.surveyor

    @members_request = @group.members_request

    @activity_feeds = ActivityFeed.includes(:member, :trackable).where(group_id: @group.id).order("created_at desc").paginate(page: params[:page], per_page: 10)
    # sleep 100
  end

  def create_group
    @init_group_company = CreateGroupCompany.new(current_member, set_company, group_params, params[:list_member])
    @group = @init_group_company.create_group

    respond_to do |wants|
      if @group
        flash[:success] = "Success"
        wants.html { redirect_to company_groups_path }
      else
        flash[:error] = "Error"
        wants.html { redirect_to company_add_group_path  }
      end
    end
  end

  def group_poll_detail
    @choice_data_chart = []
    if current_member.get_company.present?
      init_company = PollDetailCompany.new([@group], @poll)
      @member_group = init_company.get_member_in_group
      puts "member_group => #{@member_group}"
      @member_voted_poll = init_company.get_member_voted_poll
      @member_novoted_poll = init_company.get_member_not_voted_poll
      @member_viewed_poll = init_company.get_member_viewed_poll
      @member_noviewed_poll = init_company.get_member_not_viewed_poll
      @member_viewed_no_vote_poll = init_company.get_member_viewed_not_vote_poll

      if @member_group.size > 0
        @percent_vote = ((@member_voted_poll.size * 100)/@member_group.size).to_s
        @percent_novote = ((@member_novoted_poll.size * 100)/@member_group.size).to_s
        @percent_view = ((@member_viewed_poll.size * 100)/@member_group.size).to_s
        @percent_noview = ((@member_noviewed_poll.size * 100)/@member_group.size).to_s
      else
        zero_percent = "0"
        @percent_vote = zero_percent
        @percent_novote = zero_percent
        @percent_view = zero_percent
        @percent_noview = zero_percent
      end
    end
  end

  def update_group
    respond_to do |format|
      group = @group

      if group_params[:cover]
        group.cover_preset = "0"
      elsif group_params[:cover_preset]
        group.remove_old_cover
      else
        group.leave_group = group_params[:leave_group].present? ? true : false
        group.admin_post_only = group_params[:admin_post_only].present? ? true : false
        group.need_approve = group_params[:need_approve].present? ? true : false
        group.system_group = group_params[:system_group].present? ? true : false
        group.public = group_params[:public].present? ? true : false
        group.opened = group_params[:opened].present? ? true : false
      end

      if group.update(group_params)

        group.members.each do |member|
          FlushCached::Member.new(member).clear_list_groups
        end

        flash[:success] = "Successfully updated group."
        format.html { redirect_to company_group_detail_path(@group) }
        format.json
      else
        @error_message = @current_member.errors.messages

        format.json
        format.html { redirect_to company_edit_group_path(@group) }
      end
    end
  end

  def destroy_group
    @group.destroy
    flash[:success] = "Destroy #{@group.name}'group successfully"
    redirect_to company_groups_path
  end

  def delete_poll
    @poll.groups.each do |group|
      NotifyLog.update_deleted_poll_in_group(@poll, group)
    end

    unless @poll.in_group
      V1::Poll::DeleteWorker.perform_async(@poll.id)
    end

    @poll.destroy
    @poll.member.flush_cache_about_poll
    DeletePoll.create_log(@poll)
    flash[:success] = "Destroy successfully."
    redirect_to company_polls_path
  end

  def company_members
    @members = Company::ListMember.new(set_company).get_list_members
  end

  def add_member # wait for new imprement
    # puts "#{@member_in_group.map(&:id)}"
    query = Member.searchable_member(params[:q])
    @members = query

    # @member_company = Member.includes(:groups).where("groups.id IN (?) AND group_members.active = 't'", set_company.groups.map(&:id)).uniq.references(:groups)
    @member_company = Member.joins(:company_member).includes(:groups).where("company_members.company_id = ?", set_company.id).uniq.references(:groups)
  end

  def search_member
    query = Member.searchable_member(params[:q]).without_member_type(:company)
    @members = query
  end

  def add_user_to_group
    find_user = Member.cached_find(params[:member_id])
    find_group = Group.cached_find(params[:group_id])

    list_group_of_user = Member::GroupList.new(find_user)

    respond_to do |format|

      if list_group_of_user.active.map(&:id).include?(find_group.id)
        @error_message = "#{find_user.get_name} had already joined #{find_group.name}."
        format.json { render json: { error_message: @error_message }, status: :unprocessable_entity }
      else
        list_of_users = Member.where(id: find_user)
        find_group.add_user_to_group(list_of_users)

        FlushCached::Group.new(find_group).clear_list_members

        unless Rails.env.test?
          CompanyAddUserToGroupWorker.perform_async(find_user.id, find_group.id, find_group.get_company.id)
        end
        format.json { render json: { error_message: nil }, status: 200 }
      end
    end
  end

  def delete_member_company
    Group.transaction do
      find_member = Member.cached_find(params[:member_id])

      if params[:group_id].present?
        params[:group_id].each do |group_id|
          # @group = find_member.cancel_or_leave_group(group_id, "L")
          @group = Group.leave_group(find_member, Group.cached_find(group_id))
        end
      end

      @company_member = CompanyMember.remove_member_to_company(find_member, Company.find(params[:company_id]))

      respond_to do |format|
        if @company_member
          flash[:success] = "Remove successfully."
          format.html { redirect_to company_members_path }
        else
          flash[:error] = "Error"
          format.html { redirect_to company_members_path }
        end
      end
    end
  end


  def download_csv
    send_file(
      "#{Rails.root}/public/example/email_list.csv",
      filename: "email_list.csv",
      type: "application/csv"
    )
  end

  def download_excel
    send_file(
      "#{Rails.root}/public/example/email_list.xls",
      filename: "email_list.xls",
      type: "application/xls"
    )
  end

  def download_txt
    send_file(
      "#{Rails.root}/public/example/email_list.txt",
      filename: "email_list.txt",
      type: "application/txt"
    )
  end

  private

  def set_poll
    @poll = Poll.cached_find(params[:id])
    fail ExceptionHandler::Forbidden unless Company::ListPoll.new(set_company).access_poll?(@poll)
    @poll
  end

  def update_poll_params
    params.require(:poll).permit(:expire_status, :campaign_id, :draft, :close_status, :remove_campaign)
  end

  def group_params
    params.require(:group).permit(:name, :description, :photo_group, :cover, :public, :leave_group, :admin_post_only, :system_group, :need_approve, :set_group_type, :opened)
  end

  def options_params
    params.permit(:next_cursor, :type, :member_id, :since_id, :pull_request)
  end

  def invite_code_params
    params.require(:invite_code).permit(:list_email, :file, :group_id)
  end

  def find_group
    @find_group = Group.joins(:group_company).where("group_companies.company_id = #{set_company.id}").first
  end

  def set_company
    @find_company = current_member.get_company
  end

  def set_member
    @member = Member.cached_find(params[:id]).decorate
    fail ExceptionHandler::Forbidden unless Company::ListMember.new(set_company).access_member?(@member)
  end

  def set_group
    @group = Group.cached_find(params[:group_id])
  end

  def company_params
    params.require(:invite_code).permit(:amount_code, :prefix_name, :group_id)
  end

  def multi_signup_params
    params.require(:member).permit(:company_id, :password, :list_email, :file)
  end

end
