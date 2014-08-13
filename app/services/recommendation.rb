class Recommendation
  def initialize(member)
    @member = member
  end

  def get_member_recommendations
    @recommendations ||= find_brand
  end

  def mutual_friend_recommendations
    @mutual_friend = find_mutual_friend.to_a
    # puts "mutual_friend_recommendations => #{@mutual_friend}"
    return @mutual_friend
  end

  def get_list_member_recommendations
    mutual_ids = mutual_friend_recommendations.collect{|e| e["second_user"] }
    Member.without_member_type(:brand, :company, :celebrity).where("id IN (?)", mutual_ids).order("RANDOM()").limit(50)
  end

  def get_mutual_friend_recommendations_count(mutual_friend_id)
    mutual_friend_recommendations.select{|e| e if e["second_user"] == mutual_friend_id.to_s  }[0]["mutual_friend_count"]
  end

  def get_member_ids_from_mutual_and_group
    mutual_ids = mutual_friend_recommendations.collect{|e| e["second_user"].to_i } | find_non_friend_in_group
    puts "mutual_ids => #{mutual_ids}"
    Member.without_member_type(:brand, :company, :celebrity).where("id IN (?)", mutual_ids).order("RANDOM()").limit(50)
  end

  private

  def find_brand
    following = Friend.where(follower_id: @member.id, following: true, active: true, block: false).map(&:followed_id)
    query = Member.with_member_type(:brand, :celebrity).order("fullname asc")
    query = query.where("id NOT IN (?)", following) if following.length > 0

    return query
  end

  def find_mutual_friend
    # connection = ActiveRecord::Base.connection
    query = "SELECT r1.follower_id AS first_user, r2.follower_id AS second_user, COUNT(r1.followed_id) as mutual_friend_count FROM friends r1 INNER JOIN friends r2 ON r1.followed_id = r2.followed_id  "\
    "AND r1.follower_id != r2.follower_id AND r1.follower_id = #{@member.id} WHERE r1.status = 1 AND r2.status = 1 AND r1.active = 't' AND r2.active = 't' GROUP BY r1.follower_id, r2.follower_id"
    # list_recomment = ActiveRecord::Base.connection.execute(query)
    return Friend.find_by_sql(query)
  end

  def find_non_friend_in_group
    find_friend_ids = @member.get_friend_active.map(&:id) << @member.id
    puts "find_friend_ids => #{find_friend_ids}"
    find_group_and_return_member_ids = @member.cached_get_group_active.collect{|g| g.member_active.map(&:member_id) }.flatten.uniq
    puts "find_group_and_return_member_ids => #{find_group_and_return_member_ids}"
    list_non_friend_ids = find_group_and_return_member_ids - find_friend_ids
    puts "list_non_friend_ids => #{list_non_friend_ids}"
    return list_non_friend_ids
  end
  
  
end

# Friend.select('r1.follower_id AS first_user, r2.follower_id AS second_user, COUNT(r1.followed_id) as mutual_friend_count FROM friends r1 INNER JOIN friwed_id AND r1.follower_id != r2.follower_id WHERE r1.status = 1 AND r2.status = 1 AND r1.follower_id = 113 GROUP BY r1.follower_id, r2.follower_id')