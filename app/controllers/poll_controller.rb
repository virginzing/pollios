class PollController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :set_current_member, except: [:index]
  before_action :signed_user, only: [:index]

  def index
    
  end

  def create_poll
    @poll = @current_member.create_poll(poll_params)
  end

  def vote_poll
    @poll = @current_member.vote_poll(vote_params)
  end


  private

  def vote_params
    params.permit(:poll_id, :choice_id)
  end

  def poll_params
    params.permit(:group_id, :title, :expire_date, :choices => [])
  end
end
