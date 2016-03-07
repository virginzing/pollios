module Member::Private::GroupList

  private

  def ids_for(list)
    list.map(&:id)
  end

  def viewing_own_profile
    viewing_member.id == member.id
  end

  def viewing_member_visibility_for_group(group)
    group.public? || Member::GroupList.new(viewing_member).member_of?(group)
  end

  def groups_for_viewing_member
    cached_groups.select { |group| group if viewing_member_visibility_for_group(group) }
  end


  def groups
    groups = Group.joins(:group_members).without_deleted
             .select(
               "groups.*, group_members.is_master AS member_admin,
               group_members.active AS member_is_active,
               group_members.invite_id AS member_invite_id")
             .where("group_members.member_id = #{member.id}")
             .group('groups.id, member_admin, member_is_active, member_invite_id')

    groups.each do |group|
      group.member_invite_id = nil if group.member_invite_id == member.id
    end

    groups
  end

  def group_member_count
    Group.joins(:group_members_active).without_deleted
      .select('groups.*, count(group_members) AS member_count')
      .group('groups.id')
      .where('groups.id IN (?)', cached_all_groups.map(&:id))
  end

  def cached_groups
    Rails.cache.fetch("member/#{member.id}/groups") do
      groups.to_a
    end
  end
  
end