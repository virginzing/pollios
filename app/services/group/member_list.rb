class Group::MemberList
  include Group::Private::MemberList

  def initialize(group)
    @group = group
  end

  def list_members
    @list_members ||= members
  end

  # def count
  #   @list_members.count
  # end

  def active
    cached_all_members.select { |member| member if member.is_active }
  end

  def active_with_no_cache
    all_members.select { |member| member if member.is_active }
  end

  def pending
    cached_all_members.select { |member| member unless member.is_active }
  end

  def requesting
    cached_all_requests
  end

  # for testing and emergency only
  def pending_ids_non_cache
    all_members.select { |member| member unless member.is_active }.map(&:id)
  end

  def filter_members_from_list(member_list)
    group_member_ids - filter_non_members_from_list(member_list)
  end

  def filter_non_members_from_list(member_list)
    member_list - group_member_ids
  end

  def members_as_member
    cached_all_members.select { |member| member unless member.admin }
  end

  def members_as_admin
    cached_all_members.select { |member| member if member.admin }
  end

  def join_recently
    active.sort { |x, y| y.joined_at <=> x.joined_at } [0..4]
  end

  def member_or_admin?(member)
    cached_all_members.map(&:id).include?(member.id) ? true : false
  end

  def member?(member)
    members_as_member.map(&:id).include?(member.id) ? true : false
  end

  def admin?(member)
    members_as_admin.map(&:id).include?(member.id) ? true : false  
  end

  def active?(member)
    active.map(&:id).include?(member.id)
  end

  def requesting?(member)
    requesting.map(&:id).include?(member.id)
  end

  def pending?(member)
    pending.map(&:id).include?(member.id)
  end

  def raise_error_not_member(member)
    fail ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Group::NOT_IN_GROUP unless active.include?(member)
  end

  def raise_error_not_admin(member)
    fail ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Group::NOT_ADMIN unless admin?(member)
  end

  def cached_all_members
    Rails.cache.fetch("group/#{@group.id}/members") do
      all_members
    end
  end
  
  def cached_all_requests
    Rails.cache.fetch("group/#{@group.id}/requests") do
      all_requests
    end
  end
end