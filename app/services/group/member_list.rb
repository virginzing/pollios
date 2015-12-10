class Group::MemberList
  include Group::Private::MemberList

  attr_reader :group

  def initialize(group)
    @group = group
  end

  def active
    cached_all_members.select { |member| member if member.is_active }
  end

  def active_with_no_cache
    all_members.select { |member| member if member.is_active }
  end

  def pending
    cached_all_members.select { |member| member unless member.is_active } - requesting
  end

  def requesting
    cached_all_requests
  end

  # for testing and emergency only
  def pending_ids_non_cache
    all_members.select { |member| member unless member.is_active }.map(&:id)
  end

  def filter_members_from_list(member_list)
    member_list - filter_non_members_from_list(member_list)
  end

  def filter_non_members_from_list(member_list)
    member_list - group_member_ids
  end

  def members_as_member
    cached_all_members.select { |member| member if member.is_active && !member.admin }
  end

  def members_as_admin
    cached_all_members.select { |member| member if member.admin }
  end

  def join_recently
    active.sort { |x, y| y.joined_at <=> x.joined_at } [0..4]
  end

  def member_or_admin?(member)
    ids_include?(cached_all_members, member.id)
  end

  def member?(member)
    ids_include?(members_as_member, member.id)
  end

  def admin?(member)
    ids_include?(members_as_admin, member.id)  
  end

  def active?(member)
    ids_include?(active, member.id)
  end

  def requesting?(member)
    ids_include?(requesting, member.id)
  end

  def pending?(member)
    ids_include?(pending, member.id)
  end

  def raise_error_not_member(member)
    fail ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Group::NOT_IN_GROUP unless active.include?(member)
  end

  def raise_error_not_admin(member)
    fail ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Group::NOT_ADMIN unless admin?(member)
  end

  def cached_all_members
    Rails.cache.fetch("group/#{group.id}/members") do
      all_members
    end
  end
  
  def cached_all_requests
    Rails.cache.fetch("group/#{group.id}/requests") do
      all_requests
    end
  end
end