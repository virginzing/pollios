class CompaniesController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :only_company_account
  before_action :signed_user
  before_action :set_company
  before_action :find_group
  before_action :set_poll, only: [:poll_detail, :delete_poll]
  before_action :set_group, only: [:list_polls_in_group, :list_members_in_group, :destroy_group, :group_detail, :edit_group, :update_group]

  expose(:group_company) { current_member.company.groups if current_member }

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

  def remove_member
    @group = Member.find(params[:member_id]).cancel_or_leave_group(params[:group_id], "L")
    respond_to do |format|
      if @group
        flash[:success] = "Remove successfully."
        format.html { redirect_to company_groups_members_path(params[:group_id]) }
      else
        flash[:error] = "Error"
        format.html { render 'list_members' }
      end
    end
  end

  def list_polls
    @init_poll = PollOfGroup.new(current_member, current_member.company.groups, options_params)
    @polls = @init_poll.get_poll_of_group_company.paginate(page: params[:next_cursor])
  end

  def poll_detail
    @choice_data_chart = []
    if current_member.company?
      init_company = PollDetailCompany.new(@poll.groups, @poll)
      @member_group = init_company.get_member_in_group
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


  ### Group ###

  def list_group
    @member = Member.find(params[:member_id])
    @company = Company.find(params[:company_id])
    @member_group_active = @member.cached_get_group_active.map(&:id)
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

  def new_group
    @group = Group.new
    @members = Member.joins(:group_members).select("members.*, group_members.created_at as joined_at, group_members.is_master as admin")
                      .where("group_members.group_id IN (?) AND group_members.active = 't'", set_company.groups.map(&:id)) || []
  end

  def group_detail
    @init_poll = PollOfGroup.new(current_member, @group, options_params)
    @polls = @init_poll.get_poll_of_group.paginate(page: params[:next_cursor])

    @members = Member.joins(:group_members).select("members.*, group_members.created_at as joined_at, group_members.is_master as admin")
                      .where("group_members.group_id = ? AND group_members.active = 't'", @group) || []
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

  def edit_group
    
  end

  def update_group
    respond_to do |format|
      group = @group
      if group.update(group_params)
        group.get_member_active.collect {|m| Rails.cache.delete("#{m.id}/group_active") }
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
    flash[:notice] = "Destroy successfully."
    redirect_to company_polls_path
  end

  def company_members
    @members = Member.includes(:groups).where("groups.id IN (?) AND group_members.active = 't'", set_company.groups.map(&:id)).references(:groups)
  end

  def add_member # wait for new imprement
    # puts "#{@member_in_group.map(&:id)}"
    query = Member.searchable_member(params[:q]).without_member_type(:company)
    @members = query
  end

  def add_user_to_group

    find_user = Member.find_by(id: params[:member_id])     
    respond_to do |format| 
      if find_user.present?
        Group.transaction do
          find_user_group = find_user.cached_get_group_active.map(&:id)
          this_group = Group.find(params[:group_id])

          unless find_user_group.include?(this_group.id)
            this_group.group_members.create!(member_id: find_user.id, is_master: false, active: true)
            this_group.increment!(:member_count)
            find_user.cached_flush_active_group
            format.json { render json: { error_message: nil }, status: 200 }
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
      params[:group_id].each do |group_id|
        @group = Member.find(params[:member_id]).cancel_or_leave_group(group_id, "L")
      end

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

  def group_params
    params.require(:group).permit(:name, :description, :photo_group)  
  end

  def options_params
    params.permit(:next_cursor, :type, :member_id, :since_id, :pull_request)
  end

  def invite_code_params
    params.require(:invite_code).permit(:list_email, :file)
  end

  def find_group
    @find_group = Group.joins(:group_company).where("group_companies.company_id = #{@find_company.id}").first
  end

  def set_company
    @find_company = current_member.company
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

end