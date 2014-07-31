class InvitesController < ApplicationController
  layout 'admin'
  skip_before_action :verify_authenticity_token
  before_filter :authenticate_admin!, :redirect_unless_admin
  # before_action :current_admin
  before_action :set_invite_code, only: [:edit, :update, :destroy]

  def index
    @invite_codes = InviteCode.joins(:company).select("invite_codes.*, companies.name as company_name").order("invite_codes.id desc")
  end

  def new
    @company = Company.new
  end

  def create
    respond_to do |format|
      if company_params[:company_id].present?
        Company.find_by(id: company_params[:company_id].to_i).generate_code_of_company(company_params)
        flash[:success] = "Add more invite successfully."
        format.html { redirect_to invites_path }
      else
        @company = Company.new(company_params.except!(:company_id))
        @company.short_name = company_params[:prefix_name]

        if @company.save
          @company.generate_code_of_company(company_params)
          flash[:success] = "Create successfully."
          format.html { redirect_to invites_path }
        else
          format.html { render 'new' }
        end
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
    respond_to do |format|
      if @invite.destroy
        format.html { redirect_to invites_path }
      end
    end
  end

  def check_valid_company_team
    respond_to do |format|
      name_company = params[:company][:name]

      if Company.where("lower(name) = ?", name_company.downcase).present?
        format.json { render json: {"error" => "Name is already taken."}, status: 302 }
      else
        format.json { render json: true, status: 200 }
      end

    end
  end


  private

  def set_invite_code
    @invite = InviteCode.find_by(id: params[:id])
  end

  def invite_params
    params.require(:invite_code).permit(:used)
  end

  def company_params
    params.require(:company).permit(:name, :amount_code, :prefix_name, :company_id)
  end

end
