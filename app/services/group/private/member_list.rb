module Group::Private::MemberList

  private

  def group_member_ids
    queried_all_members.map(&:id) | queried_all_requests.map(&:id)
  end

  def visible?(member)
    return true unless viewing_member

    visible_member_list.include?(member)
  end

  def active?(member)
    member.is_active
  end

  def requesting?(member)
    cached_all_requests.include?(member)
  end

  def admin?(member)
    member.admin
  end

  def downcased_fullname(member)
    member.fullname.downcase
  end

  def duration_since_joined(member)
    Time.zone.now - member.joined_at
  end


  def queried_all_members
    members =
      Member
      .joins(:group_members)
      .where("group_members.group_id = #{group.id}")
      .select("
        DISTINCT members.*,
        group_members.is_master AS admin,
        group_members.active AS is_active,
        group_members.created_at AS joined_at,
        group_members.invite_id AS member_invite_id
      ")

    members.each do |member|
      member.member_invite_id = nil if member.member_invite_id == member.id
    end

    members
  end

  def queried_all_requests
    group
      .members_request
      .all
      .sort_by(&method(:downcased_fullname))
  end

  def cached_all_members
    Rails.cache.fetch("group/#{group.id}/members") do
      queried_all_members.to_a
    end
  end
  
  def cached_all_requests
    Rails.cache.fetch("group/#{group.id}/requests") do
      queried_all_requests.to_a
    end
  end

end
