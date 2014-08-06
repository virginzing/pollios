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
    @members = Member.joins(:group_members).select("members.*, group_members.created_at as joined_at").where("group_members.group_id = #{@find_group.id} AND group_members.active = 't'") || []
  end

  private

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