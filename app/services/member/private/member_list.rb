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

  def member_visibility_from(list)
    members = Member.where(id: list.to_a)

    return members.to_a unless viewing_member
    members.viewing_by_member(viewing_member).to_a
  end

  def query_friend_using_facebook
    Member.with_status_account(:normal).where(fb_id: member.list_fb_id).order('LOWER(fullname)')
  end

  def cached_all_friends
    Rails.cache.fetch("member/#{member.id}/friends") do
      all_friends.to_a
    end
  end

  def cached_all_followers
    Rails.cache.fetch("member/#{member.id}/followers") do
      all_followers.to_a
    end
  end
end