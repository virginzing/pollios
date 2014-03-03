class FriendsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :compress_gzip, only: [:list_friend, :list_request]
  before_action :set_current_member

  def add_friend
    @friend = Friend.add_friend(friend_params)
    @detail_friend, @status = @friend
  end

  def add_celebrity
    @friend = Friend.add_celebrity(friend_params)
  end

  def unfriend
    @friend = Friend.unfriend(friend_params)
  end

  def accept_friend
    @friend = Friend.accept_or_deny_freind(friend_params, true)
    @detail_friend, @status, @active = @friend
  end

  def deny_friend
    @friend = Friend.accept_or_deny_freind(friend_params, false)
  end


  def block_friend
    @friend = Friend.block_or_unblock_friend(friend_params, true)
  end

  def unblock_friend
    @friend = Friend.block_or_unblock_friend(friend_params, false)
  end

  def mute_friend
    @friend = @current_member.mute_or_unmute_friend(friend_params, true)
  end

  def unmute_friend
    @friend = @current_member.mute_or_unmute_friend(friend_params, false)
  end

  def search_friend
    @friend = Member.search_member(friend_params[:q])
    @is_friend = Friend.add_friend?(@current_member.id, @friend.id) if @friend.present?
  end

  def list_friend
    @friend_active = @current_member.get_friend_active
    # @friend_inactive = @current_member.get_friend_inactive
  end

  def list_request
    @your_request = @current_member.get_your_request
    @friend_request = @current_member.get_friend_request
  end

  private 

  def friend_params
    params.permit(:friend_id, :q, :member_id)
  end

end
