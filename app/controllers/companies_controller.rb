class CompaniesController < ApplicationController

  skip_before_action :verify_authenticity_token

  before_action :signed_user
  before_action :set_company
  before_action :find_group

  def new
    @invite = InviteCode.new
  end

  def invites
    @invite_codes = InviteCode.joins(:company).select("invite_codes.*, companies.name as company_name").where("invite_codes.company_id = ?", @find_company.id).order("invite_codes.id desc")
  end

  def create
    respond_to do |format|
      if @find_company.generate_code_of_company(company_params, find_group)
        flash[:success] = "Create invite code successfully."
        format.html { redirect_to company_invite_path }
      else
        flash[:error] = "Error"
        format.html { render 'new' }
      end
    end
  end

  def list_members
    
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