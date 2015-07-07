class CommercialsController < ApplicationController
  decorates_assigned :member
  
  layout 'admin'
  
  # skip_before_action :verify_authenticity_token
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
    company_params[:using_service] = company_params[:using_service].present? ? company_params[:using_service] : []
    if set_member.get_company.update(company_params.except(:id))
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
