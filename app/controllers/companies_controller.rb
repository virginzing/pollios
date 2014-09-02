class CompaniesController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :only_company_account
  before_action :signed_user
  before_action :set_company
  before_action :find_group

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
      endif
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
    @group = Member.find(params[:member_id]).cancel_or_leave_group(@find_group.id, "L")
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

  def list_members
    @members = Member.joins(:group_members).select("members.*, group_members.created_at as joined_at, group_members.is_master as admin").where("group_members.group_id = #{@find_group.id} AND group_members.active = 't'") || []
  end

  def add_member
    @member_in_group ||= find_group.get_member_active
    # puts "#{@member_in_group.map(&:id)}"
    query = Member.searchable_member(params[:q]).without_member_type(:company)
    @members = query
    @members = query.where("members.id NOT IN (?)", @member_in_group) if @member_in_group.count > 0
  end

  def add_user_to_group

    find_user = Member.find_by(id: params[:member_id])     
    respond_to do |format| 
      if find_user.present?
        Group.transaction do
          find_user_group = find_user.get_group_active.map(&:id)
          this_group = set_company.group

          unless find_user_group.include?(this_group.id)
            this_group.group_members.create!(member_id: find_user.id, is_master: true, active: true)
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

  def invite_code_params
    params.require(:invite_code).permit(:list_email, :file)
  end

  def find_group
    @find_group = Group.joins(:group_company).where("group_companies.company_id = #{@find_company.id}").first
  end

  def set_company
    @find_company = current_member.company
  end

  def company_params
    params.require(:invite_code).permit(:amount_code, :prefix_name)
  end

end