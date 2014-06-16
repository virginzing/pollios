class InvitesController < ApplicationController

  before_action :current_admin
  before_action :set_invite_code, only: [:edit, :update, :destroy]

  def index
    @invite_codes = InviteCode.joins(:company).select("invite_codes.*, companies.name as company_name")
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)

    respond_to do |wants|
      if @company.save
        @company.generate_code_of_company(company_params[:amount_code])
        wants.html { redirect_to invites_path }
      else
        render 'new'
      end
    end
  end

  def edit
  end

  def update
    if @invite.update(invite_params)
      flash[:success] = "Update successfully"
      redirect_to invites_path
    else
      render 'new'
    end
  end

  def destroy
    
  end



  private

  def set_invite_code
    @invite = InviteCode.find_by(id: params[:id])
  end

  def invite_params
    params.require(:invite_code).permit(:used)
  end

  def company_params
    params.require(:company).permit(:name, :amount_code)
  end

end
