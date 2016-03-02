module Group::Private::MemberList

  private

  def ids_include?(ids_list, id)
    ids_list.map(&:id).include?(id)
  end

  def group_member_query(member)
    GroupMember.where('group_id = ? AND member_id = ?', group.id, member.id)
  end

  def all_members
    Member.joins(:group_members).where("group_members.group_id = #{group.id}")
      .select(
        "DISTINCT members.*, 
        group_members.is_master as admin, 
        group_members.active as is_active, 
        group_members.invite_id as inviter_id,
        group_members.created_at as joined_at")
      .order('members.fullname asc')
  end

  def all_requests
    group.members_request.all
  end

  def member_visibility
    return all_members unless viewing_member
    all_members.viewing_by_member(viewing_member)
  end

  def group_member_ids
    all_members.map(&:id) | all_requests.map(&:id)
  end
end