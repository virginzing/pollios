class ChoicesController < ApplicationController

  before_action :set_current_poll , only: [:index]
  before_action :set_current_choice, only: [:edit, :update]
  def index
    @choices = @poll.choices
  end

  def edit
  end

  def update
    @choice.update_attributes(choice_params)
    flash[:success] = "Update successfully."
    redirect_to poll_choices_path(params[:poll_id])
  end


  private

  def choice_params
    params.require(:choice).permit(:vote)
  end

  def set_current_choice
    @choice = Choice.find(params[:id])
  end

  def set_current_poll
    @poll = Poll.find(params[:poll_id])
  end
end
