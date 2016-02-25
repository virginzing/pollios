class RecommendationLegacy
  def initialize(member)
    @member = member
    @init_list_friend = Member::MemberList.new(@member)
    @init_list_group = Member::GroupList.new(@member)
    @list_member_active = @init_list_friend.active
    @list_member_block = @init_list_friend.blocks
    @list_member_follower = @init_list_friend.followers
  end

  # conforming to the new api-service-convention/standard 
  def officials
    @officials ||= find_officials
  end

  def friends
    @friends ||= get_people_you_may_know
  end

  def groups
    @groups ||= get_group
  end

  def facebooks
    @facebooks ||= get_member_using_facebook
  end

  #ends

  def list_all_friends
    @init_list_friend.cached_all_friends.map(&:id)
  end

  def get_group
    suggest_group = SuggestGroup.cached_all
    request_group = @member.cached_ask_join_groups
    group_recommended = suggest_group.map(&:id) - @init_list_group.cached_all_groups.map(&:id) - request_group.map(&:id)
    
    Group.where(id: group_recommended)
  end

  def hash_member_count
    @group_member_count ||= group_member_count.inject({}) { |h,v| h[v.id] = v.member_count; h }
  end

  def get_friend_active
    @get_friend_active ||= @list_member_active.map(&:id)
  end

  def unrecommended
    @unrecomment_id ||= @member.cached_get_unrecomment.map(&:unrecomment_id)
  end

  def get_recommendations_official
    @recommendations ||= find_officials
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
  # def show_mutual_friend
  #   find_mutual_friend
  # end

  def get_list_member_recommendations
    mutual_ids = mutual_friend_recommendations.collect{|e| e["second_user"] }
    query = Member.without_member_type(:brand, :company, :celebrity).where("id IN (?)", mutual_ids).order("RANDOM()").limit(50)
  end

  def get_mutual_friend_recommendations_count(mutual_friend_id)
    mutual_friend_recommendations.select{|e| e if e["second_user"] == mutual_friend_id.to_s  }[0]["mutual_friend_count"]
  end

  def get_people_you_may_know
    mutual_ids = mutual_friend_recommendations.collect{|e| e["second_user"].to_i } | find_non_friend_in_group | top_10_more_friend
    query = Member.without_member_type(:brand, :company, :celebrity).with_status_account(:normal).where("id IN (?) AND members.id != ?", mutual_ids, @member.id).order("RANDOM()").limit(50)
    query = query.where("id NOT IN (?)", unrecommended) if unrecommended.size > 0
    query = query.where("id NOT IN (?)", list_block_friend_ids) if list_block_friend_ids.size > 0
    query = query.where("id NOT IN (?)", list_all_friends) if list_all_friends.size > 0
    query = query.where('id NOT IN (?)', get_member_using_facebook.map(&:id)) if get_member_using_facebook.map(&:id).size > 0
    query
  end

  # private

  def find_list_friend_ids
    @list_member_active.map(&:id) << @member.id
  end

  def list_block_friend_ids
    @list_member_block.map(&:id)
  end

  def find_officials
    following = Friend.where(follower_id: @member.id, following: true, active: true, block: false).map(&:followed_id)
    # query = Member.with_member_type(:company, :celebrity).where(show_recommend: true).order("created_at desc").limit(500)
    query = Member.where("(member_type = 3 AND show_recommend = 't') OR (member_type = 1)").order("created_at desc").limit(500)
    query = query.where("id NOT IN (?)", following) if following.size > 0
    query = query.where("id NOT IN (?)", unrecommended) if unrecommended.size > 0
    query = query.where("id NOT IN (?)", list_block_friend_ids) if list_block_friend_ids.size > 0
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
    find_group_and_return_member_ids = @init_list_group.active.collect{|group| Group::MemberList.new(group).active.map(&:id) }.flatten.uniq
    # puts "find_group_and_return_member_ids => #{find_group_and_return_member_ids}"
    list_non_friend_ids = find_group_and_return_member_ids - find_friend_ids
    # puts "list_non_friend_ids => #{list_non_friend_ids}"
    return list_non_friend_ids
  end

  def follower_recommendation
    follower_not_add_friend_yet = @list_member_follower.map(&:id) - @init_list_friend.cached_all_friends.map(&:id)
    Member.with_status_account(:normal).where(id: follower_not_add_friend_yet).limit(500)
  end

  def top_10_more_friend
    query_top_10_more_friend = Friend.select("follower_id, count(follower_id) as f_count").where("status = 1").group("friends.follower_id").sort{|x,y| y["f_count"] <=> x["f_count"] }.map(&:follower_id)[0..9]
    query_top_10_more_friend.select {|user_id| user_id unless find_list_friend_ids.include?(user_id) }
    query_top_10_more_friend
  end

  def member_using_facebook
    query = Member.with_status_account(:normal).with_member_type(:citizen).where(fb_id: @member.list_fb_id, first_signup: false)
    query = query.where("id NOT IN (?)", list_all_friends) if list_all_friends.size > 0
    query
  end

  def group_member_count
    Group.joins(:group_members_active).select("groups.*, count(group_members) as member_count").group("groups.id") \
          .where("groups.id IN (?)", get_group.map(&:id))
  end
  
end

# Friend.select('r1.follower_id AS first_user, r2.follower_id AS second_user, COUNT(r1.followed_id) as mutual_friend_count FROM friends r1 INNER JOIN friwed_id AND r1.follower_id != r2.follower_id WHERE r1.status = 1 AND r2.status = 1 AND r1.follower_id = 113 GROUP BY r1.follower_id, r2.follower_id')