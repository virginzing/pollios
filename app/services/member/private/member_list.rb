module Member::Private::MemberList

  private
  
  def ids_for(list)
    list.map(&:id)
  end

  def ids_include?(ids_list, id)
    ids_for(ids_list).include?(id)
  end

  def all_friends
    Member.joins('LEFT OUTER JOIN friends ON members.id = friends.followed_id') \
      .where("friends.follower_id = #{member.id}") \
      .select('members.*, friends.active AS member_active,
               friends.block AS member_block,
               friends.status AS member_status,
               friends.following AS member_following')
      .order('LOWER(members.fullname)')
  end

  def all_followers
    Member.joins('LEFT OUTER JOIN friends ON members.id = friends.follower_id') \
      .where("friends.followed_id = #{member.id}") \
      .select('members.*, friends.active AS member_active,
               friends.block AS member_block, 
               friends.status AS member_status,
               friends.following AS member_following')
      .order('LOWER(members.fullname)')
  end

  def visible_member_list(list)
    return list unless viewing_member
    
    list & Member.viewing_by_member(viewing_member)
  end

  def query_friend_using_facebook
    Member.with_status_account(:normal).where(fb_id: member.list_fb_id).order('LOWER(fullname)')
  end

end