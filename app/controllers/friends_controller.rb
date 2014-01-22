class FriendsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_current_member, except: [:search_friend]

  def add_friend
    @add_friend = @current_member.add_friend(friend_params)
  end

  # def block_friend
  #   @friend = @current_member.block_or_unblock_friend(friend_params, -1)
  # end

  # def unblock_friend
  #   @friend = @current_member.block_or_unblock_friend(friend_params, 1)
  # end

  def accept_friend
    @friend = @current_member.accept_or_deny_freind(friend_params, true)
  end

  def deny_friend
    @friend = @current_member.accept_or_deny_freind(friend_params, false)
  end

  def search_friend
    @friend = Member.search_member(friend_params[:q])
  end

  def list_friend
    @list_friend = @current_member.my_normally_friends
  end

  private 

  def friend_params
    params.permit(:friend_id, :q)
  end

end
