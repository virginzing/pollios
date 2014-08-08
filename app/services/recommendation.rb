class Recommendation
  def initialize(member)
    @member = member
  end

  def get_member_recommendations
    @recommendations ||= find_brand
  end

  def mutual_friend_recommendations
    @mutual_friend ||= find_mutual_friend.to_a
  end

  def get_list_member_recommendations
    mutual_ids = mutual_friend_recommendations.collect{|e| e["second_user"] }
    Member.without_member_type(:brand, :company, :celebrity).where("id IN (?)", mutual_ids)
  end

  def get_mutual_friend_recommendations_count(mutual_friend_id)
    mutual_friend_recommendations.select{|e| e if e["second_user"] == mutual_friend_id.to_s  }[0]["mutual_friend_count"]
  end

  private

  def find_brand
    Member.with_member_type(:brand).order("fullname asc")
  end

  def find_mutual_friend
    connection = ActiveRecord::Base.connection
    query = "SELECT r1.follower_id AS first_user, r2.follower_id AS second_user, COUNT(r1.followed_id) as mutual_friend_count FROM friends r1 INNER JOIN friends r2 ON r1.followed_id = r2.followed_id AND r1.follower_id != r2.follower_id WHERE r1.status = 1 AND r2.status = 1 AND r1.follower_id = #{@member.id} GROUP BY r1.follower_id, r2.follower_id"
    list_recomment = ActiveRecord::Base.connection.execute(query)
  end
  
  
end