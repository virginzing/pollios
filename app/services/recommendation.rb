class Recommendation
  def initialize(member)
    @member = member
    @init_list_friend = Member::ListFriend.new(@member)
    @init_list_group = Member::ListGroup.new(@member)
    @list_member_active = @init_list_friend.active
    @list_member_block = @init_list_friend.block
    @list_member_follower = @init_list_friend.follower
  end

  def get_group
    suggest_group = SuggestGroup.cached_all
    request_group = @member.cached_ask_join_groups
    group_recommended = suggest_group.map(&:id) - @init_list_group.cached_all_groups.map(&:id) - request_group.map(&:id)
    
    Group.where(id: group_recommended)
  end

  def get_friend_active
    @get_friend_active ||= @list_member_active.map(&:id)
  end

  def unrecommended
    @unrecomment_id ||= @member.cached_get_unrecomment.map(&:unrecomment_id)
  end

  def get_recommendations_official
    @recommendations ||= find_office_account
  end

  def get_follower_recommendations
    @follower_recommendations ||= follower_recommendation
  end

  def get_member_using_facebook
    @member_using_facebook ||= member_using_facebook
  end

  def mutual_friend_recommendations
    @mutual_friend = find_mutual_friend.to_a
    @mutual_friend = @mutual_friend.select {|e| e unless find_list_friend_ids.include?(e["second_user"].to_i) }
    return @mutual_friend
  end

  def get_list_member_recommendations
    mutual_ids = mutual_friend_recommendations.collect{|e| e["second_user"] }
    query = Member.without_member_type(:brand, :company, :celebrity).where("id IN (?)", mutual_ids).order("RANDOM()").limit(50)
  end

  def get_mutual_friend_recommendations_count(mutual_friend_id)
    mutual_friend_recommendations.select{|e| e if e["second_user"] == mutual_friend_id.to_s  }[0]["mutual_friend_count"]
  end

  def get_people_you_may_know
    # puts "find_non_friend_in_group => #{find_non_friend_in_group}"
    mutual_ids = mutual_friend_recommendations.collect{|e| e["second_user"].to_i } | find_non_friend_in_group

    puts "mutual_ids => #{mutual_ids}"
    query = Member.without_member_type(:brand, :company, :celebrity).where("id IN (?)", mutual_ids).order("RANDOM()").limit(50)
    query = query.where("id NOT IN (?)", unrecommended) if unrecommended.length > 0
    query = query.where("id NOT IN (?)", list_block_friend_ids) if list_block_friend_ids.length > 0
    query
  end

  private

  def find_list_friend_ids
    @list_member_active.map(&:id) << @member.id
  end

  def list_block_friend_ids
    @list_member_block.map(&:id)
  end

  def find_office_account
    following = Friend.where(follower_id: @member.id, following: true, active: true, block: false).map(&:followed_id)
    query = Member.with_member_type(:brand, :celebrity).order("created_at desc").limit(500)
    query = query.where("id NOT IN (?)", following) if following.length > 0
    query = query.where("id NOT IN (?)", unrecommended) if unrecommended.length > 0
    query = query.where("id NOT IN (?)", list_block_friend_ids) if list_block_friend_ids.length > 0
    query = query.where("id NOT IN (?)", get_friend_active) if get_friend_active.size > 0
    query = query.where("id != ?", @member.id)
    return query
  end

  def find_mutual_friend
    # connection = ActiveRecord::Base.connection
    query = "SELECT r1.follower_id AS first_user, r2.follower_id AS second_user, COUNT(r1.followed_id) as mutual_friend_count FROM friends r1 INNER JOIN friends r2 ON r1.followed_id = r2.followed_id  "\
    "AND r1.follower_id != r2.follower_id WHERE r1.status = 1 AND r2.status = 1 AND r1.follower_id = #{@member.id} GROUP BY r1.follower_id, r2.follower_id"
    # list_recomment = ActiveRecord::Base.connection.execute(query)
    return Friend.find_by_sql(query)
  end

  def find_non_friend_in_group
    find_friend_ids = find_list_friend_ids
    # puts "find_friend_ids => #{find_friend_ids}"
    find_group_and_return_member_ids = @init_list_group.active.collect{|group| Group::ListMember.new(group).active.map(&:id) }.flatten.uniq
    # puts "find_group_and_return_member_ids => #{find_group_and_return_member_ids}"
    list_non_friend_ids = find_group_and_return_member_ids - find_friend_ids
    # puts "list_non_friend_ids => #{list_non_friend_ids}"
    return list_non_friend_ids
  end

  def follower_recommendation
    follower_not_add_friend_yet = @list_member_follower.map(&:id) - @init_list_friend.cached_all_friends.map(&:id)
    Member.having_status_account(:normal).where(id: follower_not_add_friend_yet).limit(500)
  end

  def member_using_facebook
    Member.having_status_account(:normal).where(fb_id: @member.list_fb_id).order("fullname asc").limit(500)
  end
  
end

# Friend.select('r1.follower_id AS first_user, r2.follower_id AS second_user, COUNT(r1.followed_id) as mutual_friend_count FROM friends r1 INNER JOIN friwed_id AND r1.follower_id != r2.follower_id WHERE r1.status = 1 AND r2.status = 1 AND r1.follower_id = 113 GROUP BY r1.follower_id, r2.follower_id')