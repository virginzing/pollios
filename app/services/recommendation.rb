class Recommendation
  def initialize(member)
    @member = member
  end

  def unrecommented
    @unrecomment_id ||= @member.cached_get_unrecomment.map(&:unrecomment_id)
  end

  def get_member_recommendations
    @recommendations ||= find_brand
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

  def get_member_ids_from_mutual_and_group
    mutual_ids = mutual_friend_recommendations.collect{|e| e["second_user"].to_i } | find_non_friend_in_group
    query = Member.without_member_type(:brand, :company, :celebrity).where("id IN (?)", mutual_ids).order("RANDOM()").limit(50)
    query = query.where("id NOT IN (?)", unrecommented) if unrecommented.length > 0
    query
  end

  private

  def find_list_friend_ids
    @list_friend = @member.get_friend_active.map(&:id) << @member.id
  end

  def find_brand
    following = Friend.where(follower_id: @member.id, following: true, active: true, block: false).map(&:followed_id)
    query = Member.with_member_type(:brand, :celebrity).order("fullname asc")
    query = query.where("id NOT IN (?)", following) if following.length > 0
    query = query.where("id NOT IN (?)", unrecommented) if unrecommented.length > 0
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
    puts "find_friend_ids => #{find_friend_ids}"
    find_group_and_return_member_ids = @member.cached_get_group_active.collect{|g| g.member_active.map(&:member_id) }.flatten.uniq
    puts "find_group_and_return_member_ids => #{find_group_and_return_member_ids}"
    list_non_friend_ids = find_group_and_return_member_ids - find_friend_ids
    puts "list_non_friend_ids => #{list_non_friend_ids}"
    return list_non_friend_ids
  end
  
  
end

# Friend.select('r1.follower_id AS first_user, r2.follower_id AS second_user, COUNT(r1.followed_id) as mutual_friend_count FROM friends r1 INNER JOIN friwed_id AND r1.follower_id != r2.follower_id WHERE r1.status = 1 AND r2.status = 1 AND r1.follower_id = 113 GROUP BY r1.follower_id, r2.follower_id')