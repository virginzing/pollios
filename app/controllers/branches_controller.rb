class BranchesController < ApplicationController

  skip_before_action :verify_authenticity_token

  before_action :signed_user
  before_action :load_company
  before_action :set_branch, only: [:edit, :update, :destroy]


  def detail
    @branch = Branch.find(params[:branch_id])
    @questionnaire = Groupping.where("groupable_id IN (?) AND groupable_type = 'PollSeries' AND collection_poll_id = ?", @branch.branch_poll_series.map(&:poll_series_id), params[:id]).first.groupable
    @qr = RQRCode::QRCode.new(GenerateQrcodeLink.new(@questionnaire).get_redirect_link, :size => 8, :level => :h ).to_img.resize(200, 200).to_data_url                             
  end

  def index
    @branches = @company.branches.order("branches.created_at DESC")
  end

  def new
    @branch = Branch.new
  end

  def create
    @branch = @company.branches.new(branch_params)

    if @branch.save
      flash[:success] = "Successfully created..."
      redirect_to branches_path
    else
      flash[:error] = "Invalid"
      render 'new'
    end

  end

  def edit

  end

  def update
    if @branch.update(branch_params)
      flash[:success] = "Successfully updated..."
      redirect_to branches_path
    else
      flash[:error] = "Invalid"
      render 'new'
    end
  end

  def destroy
    @branch.destroy
    flash[:success] = "Successfully destroy..."
    redirect_to branches_path
  end


  private

  def set_branch
    @branch = Branch.find(params[:id])
  end

  def branch_params
    params.require(:branch).permit(:name, :address)
  end

end
