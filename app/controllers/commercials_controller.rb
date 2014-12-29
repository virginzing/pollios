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
    if set_member.get_company.update(company_params)
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
