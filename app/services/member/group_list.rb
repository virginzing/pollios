class Member::GroupList
  include Member::Private::GroupList

  attr_reader :member, :viewing_member
  
  def initialize(member, options = {})
    @member = @viewing_member = member

    return unless options[:viewing_member]
    @viewing_member = options[:viewing_member]
  end

  def relation_status_ids
    {
      admin_ids: ids_for(as_admin),
      member_ids: ids_for(as_member),
      pending_ids: ids_for(got_invitations),
      requesting_ids: ids_for(requesting_to_joins)
    }
  end

  def cached_all_groups
    return @cached_all_groups ||= cached_groups if viewing_own_profile

    @cached_all_groups ||= groups_for_viewing_member
  end

  def member_of?(group)
    groups_ids.include?(group.id)
  end

  def groups_ids
    cached_all_groups.map(&:id)
  end

  def active_ids
    active.map(&:id)
  end

  def active
    cached_all_groups.select { |group| group if group.member_is_active }
  end

  def as_member
    active.select { |group| group if group.member_is_active && !group.member_admin }
  end

  def as_admin
    active.select { |group| group if group.member_admin }
  end

  def as_admin_with_requests
    active.select { |group| group if group.member_admin && group.members_request.size > 0 }
  end

  def got_invitations
    cached_all_groups.select { |group| group unless group.member_is_active } - requesting_to_joins
  end

  def requesting_to_joins
    cached_requesting_to_joins
  end

  def public_groups_for_company_available?
    member.get_company.using_public? && !member.get_company.using_internal?
  end

  # TODO: this should be broken. it works basically because we have no virtual group.
  # TODO: refactor or remove. either way.
  def active_non_virtual
    list_groups = cached_all_groups.select { |group| group if group.member_is_active && !group.virtual_group }
    if member.company? 
      list_groups.select! { |elem| elem if elem.public } if public_groups_for_company_available?
    end
    list_groups
  end

  def groups_available_for_poll(poll, requesting_group_id = nil)
    tmp_member = tmp_non_member = []

    poll_groups = poll.groups.sort
    poll_groups.each do |group|
      if member_of?(group)
        if requesting_group_id == group.id
          tmp_member.unshift(group)
        else
          tmp_member << group
        end
      else
        tmp_non_member << group if group.public
      end
    end

    tmp_member | tmp_non_member
  end

  def active_with_public
    cached_all_groups.select { |group| group if group.member_is_active && group.public == false }
  end

  def inactive
    cached_all_groups.select { |group| group unless group.member_is_active }
  end

  def hash_member_count
    @group_member_count ||= group_member_count.each_with_object({}) { |group, hash| hash[group.id] = group.member_count }
  end

end