class MembersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_current_member, except: [:index, :profile, :clear]
  before_action :history_voted_viewed, only: [:detail_friend]
  before_action :compress_gzip, only: [:detail_friend]

  expose(:list_friend) { current_member.friend_active.pluck(:followed_id) }
  expose(:friend_request) { current_member.get_your_request.pluck(:id) }
 
  def detail_friend
    @find_friend = Member.find(params[:friend_id])
    poll = @find_friend.polls.includes(:member)
    @poll_series, @poll_nonseries, @next_cursor = Poll.split_poll(poll, @current_member.id)
    @is_friend = Friend.add_friend?(@current_member.id, @find_friend.id) if @find_friend.present?
  end

  def index
    @members = Member.paginate(page: params[:page])
  end

  def profile
  end

  def clear
    current_member.history_votes.delete_all
    flash[:success] = "Clear successfully."
    redirect_to root_url
  end
end
