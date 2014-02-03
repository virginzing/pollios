class MembersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_current_member
  before_action :history_voted_viewed, only: [:detail_friend]
  before_action :compress_gzip, only: [:detail_friend]

  def detail_friend
    find_friend = Member.find(params[:friend_id])
    @detail_friend = find_friend
    @is_friend = Friend.add_friend?(@current_member.id, find_friend.id) if find_friend.present?
  end
end
