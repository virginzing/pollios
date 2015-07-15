class Company::FollowOwnerGroup

  def initialize(member, following_id)
    @member = member
    @following_id = following_id
  end

  def follow!
    begin
      Friend.add_following(@member, { member_id: @member.id, friend_id: @following_id})
    rescue => e
      true
    end
  end

end
