class CompaniesController < ApplicationController
  decorates_assigned :poll, :member

  skip_before_action :verify_authenticity_token

  before_action :signed_user
  before_action :set_company
  before_action :check_using_service
  before_action :find_group
  before_action :set_poll, only: [:poll_detail, :delete_poll, :group_poll_detail, :edit_poll]
  before_action :set_group, only: [:remove_surveyor, :list_polls_in_group, :list_members_in_group, :destroy_group, :group_detail, :edit_group, :update_group, :group_poll_detail]

  before_action :set_questionnaire, only: [:questionnaire_detail]

  expose(:group_company) { current_member.get_company.groups if current_member }

  def dashboard
    @init_poll ||= PollOfGroup.new(current_member, current_member.get_company.groups, options_params)
    @poll_latest_list = @init_poll.get_poll_of_group_company.limit(5)

    @poll_popular_list = @init_poll.get_poll_of_group_company.where("vote_all != 0").order("vote_all desc").limit(5)
    render 'home/dashboard_company'

    # session[:name] = "NUTTY"
  end

  def new
    @invite = InviteCode.new
  end

  def invites
    @invite_codes = InviteCode.joins(:company).includes(:member_invite_code => :member)
                              .select("invite_codes.*, companies.name as company_name")
                              .where("invite_codes.company_id = ?", @find_company.id)
                              .order("invite_codes.id desc")
    @invite = InviteCode.new
  end

  def search
    @search = Poll.includes(:choices, :member).select('polls.*').joins(:groups)
                  .where("poll_groups.group_id IN (?)", current_member.get_company.groups.map(&:id)).uniq
                  .where("polls.title LIKE (?)", "%#{params[:q]}%")
                  .order("polls.created_at DESC")
                  .paginate(page: params[:page], per_page: 10).decorate
  end


  def poll_flags
    @report_polls = Company::CompanyReportPoll.new(company_groups).get_report_poll_in_company  
  end

  def via_email
    @via_email = InviteCode.new
  end

  def send_email
    list_email_text = invite_code_params[:list_email].split("\r\n")
    list_email_file = []
    file = invite_code_params[:file]

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

    
    total_email = ( list_email_text | list_email_file.collect).collect{|e| e.downcase }.uniq

    # puts "total email #{total_email}"

    respond_to do |format|
      @send_email = SendInvitesWorker.perform_async(total_email, @find_group.id, @find_company.id )

      if @send_email
        flash[:success] = "Send invite code via email successfully."
        format.html { redirect_to company_invites_path }
      else
        flash[:error] = "Error"
        format.html { redirect_to via_email_path } 
      end
    end
  end

  def create
    respond_to do |format|
      if @find_company.generate_code_of_company(company_params, find_group)
        flash[:success] = "Create invite code successfully."
        format.html { redirect_to company_invites_path }
      else
        flash[:error] = "Error"
        format.html { render 'new' }
      end
    end
    # add comment
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
        if email_signup_success.count > 0
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
    @group = Member.find(params[:member_id]).cancel_or_leave_group(params[:group_id], "L")
    respond_to do |format|
      if @group
        # Group.flush_cached_member_active(@group.id)
        flash[:success] = "Remove successfully."
        format.html { redirect_to company_groups_members_path(params[:group_id]) }
      else
        flash[:error] = "Error"
        format.html { render 'list_members' }
      end
    end
  end

  def list_polls  ## company polls
    @init_poll = PollOfGroup.new(current_member, current_member.get_company.groups, options_params, true)
    @polls = @init_poll.get_poll_of_group_company.decorate

    @init_poll_public = Company::PollPublic.new(@find_company)
    @public_polls = @init_poll_public.get_list_public_poll.decorate
  end

  def list_questionnaires
    @list_questionnaires = current_member.poll_series.where(feedback: false)
  end

  def list_campaigns
    @list_campaigns = current_member.campaigns.includes(:polls)
  end

  def setting

  end

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
      if @member_group.count > 0
        @percent_vote = ((@member_voted_poll.count * 100)/@member_group.count).to_s
        @percent_novote = ((@member_novoted_poll.count * 100)/@member_group.count).to_s
        @percent_view = ((@member_viewed_poll.count * 100)/@member_group.count).to_s
        @percent_noview = ((@member_noviewed_poll.count * 100)/@member_group.count).to_s
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
    if @poll.update(update_poll_params)
      flash[:success] = "Successfully updated..."
      redirect_to company_poll_detail_path
    else
      flash[:error] = "Something weng wrong"
      redirect_to company_edit_poll_path(@poll)
    end
  end

  def questionnaire_detail
    @questionnaire = @questionnaire.decorate

    @array_list = []

    @questionnaire.polls.each do |poll|
      @array_list << poll.choices.collect!{|e| e.answer.to_i * e.vote.to_f }.reduce(:+).round(2)
    end

    @qr = RQRCode::QRCode.new(GenerateQrcodeLink.new(@questionnaire).get_redirect_link, :size => 8, :level => :h ).to_img.resize(200, 200).to_data_url

  end


  ### Group ###

  def list_group
    @member = Member.cached_find(params[:member_id])
    init_list_group = Member::ListGroup.new(@member)

    @company = Company.find(params[:company_id])
    @member_group_active = init_list_group.active.map(&:id)
    render layout: false
  end

  def company_groups
    @groups = Group.eager_load(:group_company, :poll_groups, :group_members).where("group_companies.company_id = #{set_company.id}").uniq
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
    @member = Member.find(params[:id]).decorate
    member_with_group = @member.get_group_active.with_group_type(:company)
    
    @init_poll = PollOfGroup.new(current_member,member_with_group, options_params, true)

    list_voted_poll_ids = @member.cached_my_voted_all.collect{|e| e["poll_id"] }

    if member_with_group.present?
      query = @init_poll.get_poll_of_group_company
      query = query.where("polls.id NOT IN (?)", list_voted_poll_ids) if list_voted_poll_ids.count > 0
      @list_unvote_poll = query.decorate
    else
      @list_unvote_poll = []
    end

  end

  def new_group
    @group = Group.new
    @members = Member.joins(:group_members).select("DISTINCT members.*").where("group_members.group_id IN (?) AND group_members.active = 't'", set_company.groups.map(&:id)) || []
  end

  def new_add_surveyor
    @groups = Group.eager_load(:group_company, :poll_groups, :group_members).where("group_companies.company_id = #{set_company.id}").uniq
    @list_members_in_company = Member.includes(:groups).where("groups.id IN (?) AND group_members.active = 't'", set_company.groups.map(&:id)).uniq.references(:groups)
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
    @init_poll = PollOfGroup.new(current_member, @group, options_params)
    @polls = @init_poll.get_poll_of_group

    @member_all = Member.joins(:group_members).select("members.*, group_members.created_at as joined_at, group_members.is_master as admin, group_members.active as member_is_active")
                      .where("group_members.group_id = ?", @group).uniq || []

    @members = @member_all.select {|member| member if member.member_is_active }
    @members_inactive = @member_all.select {|member| member unless member.member_is_active }

    @list_surveyor = @group.surveyor

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

      if @member_group.count > 0
        @percent_vote = ((@member_voted_poll.count * 100)/@member_group.count).to_s
        @percent_novote = ((@member_novoted_poll.count * 100)/@member_group.count).to_s
        @percent_view = ((@member_viewed_poll.count * 100)/@member_group.count).to_s
        @percent_noview = ((@member_noviewed_poll.count * 100)/@member_group.count).to_s
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
      group.leave_group = group_params[:leave_group].present? ? true : false
      group.admin_post_only = group_params[:admin_post_only].present? ? true : false

      if group.update(group_params)
        Company::TrackActivityFeedGroup.new(current_member, group, "update").tracking

        group.members.each do |member|
          FlushCached::Member.new(member).clear_list_groups
        end
        # group.get_member_active.collect {|m| Rails.cache.delete("#{m.id}/group_active") }

        flash[:success] = "Update group profile successfully."
        format.html { redirect_to company_group_detail_path(@group) }
        format.json
      else
        # puts "have error"
        @error_message = @current_member.errors.messages

        format.json
        format.html { render 'profile' ,errors: @error_message }
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
      group.decrement!(:poll_count)
    end
    @poll.destroy
    @poll.member.flush_cache_about_poll
    DeletePoll.create_log(@poll)
    flash[:notice] = "Destroy successfully."
    redirect_to company_polls_path
  end

  def company_members
    # @members = Member.includes(:groups).where("groups.id IN (?) AND group_members.active = 't'", set_company.groups.map(&:id)).uniq.references(:groups)
    @members = Member.joins(:company_member).includes(:groups).where("company_members.company_id = ?", set_company.id).uniq.references(:groups)
  end

  def add_member # wait for new imprement
    # puts "#{@member_in_group.map(&:id)}"
    query = Member.searchable_member(params[:q]).without_member_type(:company)
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

    init_list_group = Member::ListGroup.new(find_user)

    respond_to do |format| 
      if find_user.present?
        Group.transaction do
          find_user_group = init_list_group.active.map(&:id)

          this_group = Group.find(params[:group_id])

          unless find_user_group.include?(this_group.id)
            begin
              this_group.group_members.create!(member_id: find_user.id, is_master: false, active: true)

              CompanyMember.add_member_to_company(find_user, @find_company)

              Company::TrackActivityFeedGroup.new(find_user, this_group, "join").tracking
              
              this_group.increment!(:member_count)
              # find_user.cached_flush_active_group
              FlushCached::Member.new(find_user).clear_list_groups
              # Group.flush_cached_member_active(this_group.id)

              format.json { render json: { error_message: nil }, status: 200 }
            rescue ActiveRecord::RecordNotUnique
              @error_message = "This member join another company already"
              format.json { render json: { error_message: @error_message }, status: 403 }
            end

          else
            @error_message = "You already joined in this group."
            format.json { render json: { error_message: @error_message }, status: 403 }
          end

        end
      else
        @error_message = "Not found this user."
        format.json { render json: { error_message: @error_message }, status: 403 }
      end

    end
  end

  def delete_member_company
    Group.transaction do 
      find_member = Member.find(params[:member_id])

      params[:group_id].each do |group_id|
        @group = find_member.cancel_or_leave_group(group_id, "L")
        # Group.flush_cached_member_active(group_id)
      end

      CompanyMember.remove_member_to_company(find_member, Company.find(params[:company_id]))

      respond_to do |format|
        if @group
          flash[:success] = "Remove successfully."
          format.html { redirect_to company_members_path }
        else
          flash[:error] = "Error"
          format.html { render 'list_members' }
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
  end

  def update_poll_params
    params.require(:poll).permit(:expire_status, :campaign_id, :draft)  
  end

  def set_questionnaire
    @questionnaire = PollSeries.cached_find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name, :description, :photo_group, :cover, :public, :leave_group, :admin_post_only, :system_group, :need_approve)  
  end

  def options_params
    params.permit(:next_cursor, :type, :member_id, :since_id, :pull_request)
  end

  def invite_code_params
    params.require(:invite_code).permit(:list_email, :file)
  end

  def find_group
    @find_group = Group.joins(:group_company).where("group_companies.company_id = #{set_company.id}").first
  end

  def set_company
    @find_company = current_member.company || current_member.company_member.company
  end

  def set_group
    begin
      @group = Group.find(params[:group_id])
      raise ExceptionHandler::NotFound, "Group not found" unless @group.present?
    end
  end

  def company_params
    params.require(:invite_code).permit(:amount_code, :prefix_name)
  end

  def multi_signup_params
    params.require(:member).permit(:company_id, :password, :list_email, :file)
  end

end