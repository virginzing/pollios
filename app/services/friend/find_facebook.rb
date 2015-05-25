class Friend::FindFacebook
  def initialize(member, list_fb_id)
    @member = member
    @list_fb_id = list_fb_id
  end

  def list_fb_id
    @list_fb_id || []  
  end

  def init_list_friend
    @init_list_friend ||= Member::ListFriend.new(@member)
  end

  def list_all_friend
    init_list_friend.cached_all_friends
  end


  def get_friend_facebook
    @get_friend_facebook ||= query_member
  end


  private

  def query_member
    query = Member.with_status_account(:normal).where(fb_id: list_fb_id).order("fullname asc")
  end
  
end