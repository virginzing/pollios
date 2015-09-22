class Member::ListGroup
  def initialize(member)
    @member = member
  end

  def cached_all_groups
    @cached_all_groups ||= cached_groups
  end

  def active
    cached_all_groups.select{|group| group if group.member_is_active }
  end

  def as_admin
    active.select{|group| group if group.member_admin }
  end

  def active_non_virtual
    list_groups = cached_all_groups.select{|group| group if group.member_is_active && !group.virtual_group }
    if @member.company? 
      if @member.get_company.using_public? && !@member.get_company.using_internal?
        list_groups.select! {|elem| elem if elem.public }
      end
    end
    list_groups
  end

  def groups_available_for_poll(poll, requesting_group_id = {})
    member_groups_ids = @member.groups.map(&:id)

    tmp_member = []
    tmp_non_member = []

    poll_groups = cached_groups_for_poll(poll)
    poll_groups.each do |group|
      if member_groups_ids.include?(group.id)
        if requesting_group_id == group.id
          tmp_member.insert(0, group)
        else
          tmp_member << group
        end
      else
        if group.public
          tmp_non_member << group
        end
      end
    end

    tmp_member | tmp_non_member
  end

  def active_with_public
    cached_all_groups.select{|group| group if group.member_is_active && group.public == false }
  end

  def inactive
    cached_all_groups.select{|group| group unless group.member_is_active }
  end

  def hash_member_count
    @group_member_count ||= group_member_count.inject({}) { |h,v| h[v.id] = v.member_count; h }
  end

  private

  def groups
    Group.joins(:group_members).without_deleted.select("groups.*, group_members.is_master as member_admin, group_members.active as member_is_active, group_members.invite_id as member_invite_id") \
          .where("group_members.member_id = #{@member.id}").group("groups.id, member_admin, member_is_active, member_invite_id")
  end

  def group_member_count
    Group.joins(:group_members_active).without_deleted.select("groups.*, count(group_members) as member_count").group("groups.id") \
          .where("groups.id IN (?)", cached_all_groups.map(&:id))
  end

  def cached_groups
    Rails.cache.fetch("member/#{@member.id}/groups") do
      groups.to_a
    end
  end

  def cached_groups_for_poll(poll)
    Rails.cache.fetch("poll/#{poll.id}/groups") do
      poll.groups
    end
  end
end