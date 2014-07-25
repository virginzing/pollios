class RecurringsController < ApplicationController

  protect_from_forgery
  skip_before_action :verify_authenticity_token, if: :json_request?

  before_action :set_recurring, only: [:show, :edit, :update, :destroy]
  before_action :signed_user, only: [:new]
  # GET /recurrings
  # GET /recurrings.json
  def index
    @recurrings = Recurring.all
  end

  # GET /recurrings/1
  # GET /recurrings/1.json
  def show
  end

  # GET /recurrings/new
  def new
    @recurring = Recurring.new
  end

  # GET /recurrings/1/edit
  def edit
  end

  # POST /recurrings
  # POST /recurrings.json
  def create
    @recurring = current_member.recurrings.new(recurring_params)

    respond_to do |format|
      if @recurring.save
        format.html { redirect_to @recurring, notice: 'Recurring was successfully created.' }
        format.json { render action: 'show', status: :created, location: @recurring }
      else
        format.html { render action: 'new' }
        format.json { render json: @recurring.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /recurrings/1
  # PATCH/PUT /recurrings/1.json
  def update
    respond_to do |format|
      if @recurring.update(recurring_params)
        format.html { redirect_to @recurring, notice: 'Recurring was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @recurring.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recurrings/1
  # DELETE /recurrings/1.json
  def destroy
    @recurring.destroy
    respond_to do |format|
      format.html { redirect_to recurrings_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recurring
      @recurring = Recurring.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def recurring_params
      params.require(:recurring).permit(:period, :status, :member_id, :end_recur, :description)
    end
    
  protected

  def json_request?
    request.format.json?
  end

end
