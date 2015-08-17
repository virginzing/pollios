class TriggersController < ApplicationController
  layout 'admin'

  before_action :find_trigger, only: [:destroy]

  def index
    @list_triggers = Trigger.all
  end

  def new

  end

  def create
    build_trigger = Trigger::BuildTrigger.new(params).setup

    if build_trigger
      flash[:success] = "Create success"
      redirect_to triggers_path
    else
      flash[:error] = "Select a element of choices less than 1 choice"
      redirect_to new_trigger_path
    end

  end

  def destroy
    @trigger.destroy
    flash[:success] = "Successfully destroy..."
    redirect_to triggers_path
  end


  private

  def find_trigger
    @trigger = Trigger.find(params[:id])
  end
end
