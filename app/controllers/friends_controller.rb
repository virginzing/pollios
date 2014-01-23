class FriendsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_current_member

  def add_friend
    @friend = @current_member.add_friend(friend_params)
    @detail_friend, @active = @friend
  end

  def block_friend
    @friend = @current_member.block_or_unblock_friend(friend_params, true)
  end

  def unblock_friend
    @friend = @current_member.block_or_unblock_friend(friend_params, false)
  end

  def mute_friend
    @friend = @current_member.mute_or_unmute_friend(friend_params, true)
  end

  def unmute_friend
    @friend = @current_member.mute_or_unmute_friend(friend_params, false)
  end

  def accept_friend
    @friend = @current_member.accept_or_deny_freind(friend_params, true)
  end

  def deny_friend
    @friend = @current_member.accept_or_deny_freind(friend_params, false)
  end

  def unfriend
    @friend = @current_member.unfriend(friend_params[:friend_id])
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
