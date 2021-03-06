class ChoicesController < ApplicationController

  before_action :set_current_poll , only: [:index]
  before_action :set_current_choice, only: [:edit, :update]
  
  def load_choice
    @choices = Choice.where(poll_id: params[:poll_id])

    @groups_system ||= Group.where(system_group: true)

    render layout: false  
  end

  def load_choices_as_checkbox
    @choices = Choice.where(poll_id: params[:poll_id])

    render layout: false    
  end

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
