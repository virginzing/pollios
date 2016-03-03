module Group::Private::MemberList

  private

  def ids_include?(ids_list, id)
    ids_list.map(&:id).include?(id)
  end

  def group_member_query(member)
    GroupMember.where('group_id = ? AND member_id = ?', group.id, member.id)
  end

  def all_members
    members = Member.joins(:group_members).where("group_members.group_id = #{group.id}")
              .select(
                "DISTINCT members.*, 
                 group_members.is_master AS admin, 
                 group_members.active AS is_active, 
                 group_members.invite_id AS inviter_id,
                 group_members.created_at AS joined_at,
                 group_members.invite_id AS member_invite_id")

    members.each do |member|
      member.member_invite_id = nil if member.member_invite_id == member.id
    end

    members
  end

  def all_requests
    sort_by_name(group.members_request.all)
  end

  def member_visibility
    return sort_by_name(all_members) unless viewing_member
    sort_by_name(all_members.viewing_by_member(viewing_member))
  end

  def group_member_ids
    all_members.map(&:id) | all_requests.map(&:id)
  end

  def sort_by_name(list)
    list.sort_by { |m| m.fullname.downcase }
  end
end