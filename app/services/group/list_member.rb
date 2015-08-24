class Group::ListMember
  def initialize(group)
    @group = group
  end

  def list_members
    @list_members ||= members
  end

  def cached_all_members
    @cached_all_members ||= cached_members
  end

  def active
    cached_all_members.select{|member| member if member.is_active }
  end

  def active_with_no_cache
    members.select{|member| member if member.is_active }
  end

  def pending
    cached_all_members.select{|member| member unless member.is_active }
  end

   # for testing and emergency only
  def pending_ids_non_cache
    members.select{|member| member unless member.is_active }
    members.map(&:id)
  end


  def members_as_member
    cached_all_members.select{ |member| member unless member.admin }
  end

  def members_as_admin
    cached_all_members.select{ |member| member if member.admin }
  end

  def join_recently
    active.sort {|x,y| y.joined_at <=> x.joined_at }[0..4]
  end

  def is_member?(member)
    members_as_member.map(&:id).include?(member.id) ? true : false
  end

  def is_admin?(member)
    members_as_admin.map(&:id).include?(member.id) ? true : false  
  end

  def raise_error_not_member(member)
    fail ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Group::NOT_IN_GROUP unless active.include?(member)
  end

  def raise_error_not_admin(member)
    fail ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Group::NOT_ADMIN unless is_admin?(member)
  end

  # NOT TESTED
  def filter_new_member(member_id_list)
    return member_id_list - @group.group_members.map(&:member_id)
  end

  private

  def members
    Member.joins(:group_members).where("group_members.group_id = #{@group.id}")
          .select("DISTINCT members.*, group_members.is_master as admin, group_members.active as is_active, group_members.created_at as joined_at").order("members.fullname asc")

  end
  
  def cached_members
    Rails.cache.fetch("group/#{@group.id}/members") do
      members.to_a
    end
  end
  
end