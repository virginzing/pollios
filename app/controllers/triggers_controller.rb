class TriggersController < ApplicationController
  layout 'admin'

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
    end
    
  end
end
