class PollController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :set_current_member, except: [:index]
  before_action :signed_user, only: [:index]
  before_action :history_voted_viewed, only: [:public_poll, :group_poll]

  def index
    
  end

  def public_poll
    @poll = Poll.get_public_poll(@current_member, { next_poll: params[:next_poll], type: params[:type]})
  end

  def group_poll
    @poll = Poll.get_group_poll(@current_member, {next_poll: params[:next_poll]})
  end

  def create_poll
    @poll = Poll.create_poll(poll_params, @current_member)
  end

  def vote_poll
    @poll, @history_voted = Poll.vote_poll(vote_params)
    @vote = Hash["voted" => true, "choice_id" => @history_voted.choice_id] if @history_voted
  end

  def view_poll
    @poll = Poll.view_poll(vote_params)
  end

  private

  def vote_params
    params.permit(:poll_id, :choice_id, :member_id)
  end

  def poll_params
    params.permit(:title, :expire_date, :member_id, :friend_id, :choices, :group_id)
  end
  
end
