class CommercialsController < ApplicationController

  layout 'admin'
  decorates_assigned :member
  before_filter :authenticate_admin!, :redirect_unless_admin

  def index
    @commercials = Member.with_member_type(:company)
  end

  def new

  end

  def edit
    @member = Member.find(params[:id])
  end

  def update
    find_company = set_member.get_company
    if find_company.update(company_params.except(:id))
      find_company.using_service = [] unless company_params[:using_service].present?
      find_company.save!
      flash[:success] = "Update Successfully"
      redirect_to commercials_path
    else
      flash[:error] = "Update fail"
      render 'edit'
    end
  end


  private

  def set_member
    @member = Member.find(params[:id])
  end

  def company_params
    params.permit(:id, :using_service => [])
  end

end
