class ChoicesController < ApplicationController

  before_action :set_current_poll , only: [:index]

  def index
    @choices = @poll.choices
  end


  private

  def set_current_poll
    @poll = Poll.find(params[:poll_id])
  end
end
