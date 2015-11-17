module Member::Private::MemberList

  private
  def ids_for(list)
    list.map(&:id)
  end

  def ids_include?(ids_list, id)
    ids_for(ids_list).include?(id)
  end

  def all_friends
    Member.joins('inner join friends on members.id = friends.followed_id') \
      .where("friends.follower_id = #{member.id}") \
      .select('members.*, friends.active as member_active, friends.block as member_block, 
              friends.status as member_status, friends.following as member_following')
      .to_a
  end

  def all_followers
    Member.joins('inner join friends on members.id = friends.follower_id') \
      .where("friends.followed_id = #{member.id}") \
      .select('members.*, friends.active as member_active, friends.block as member_block, 
              friends.status as member_status, friends.following as member_following')
      .to_a
  end

  def query_friend_using_facebook
    Member.with_status_account(:normal).where(fb_id: member.list_fb_id).order('fullname asc')
  end
end