class Group::MemberList
  include Group::Private::MemberList

  attr_reader :group, :viewing_member

  def initialize(group, options = {})
    @group = group

    return unless options[:viewing_member]
    @viewing_member = options[:viewing_member]
  end

  def active
    member_visibility_from(cached_all_members.select { |member| member if member.is_active })
  end

  def active_with_no_cache
    all_members.select { |member| member if member.is_active }
  end

  def pending
    member_visibility_from(cached_all_members.select { |member| member unless member.is_active } - requesting)
  end

  def requesting
    cached_all_requests
  end

  # for testing and emergency only
  def pending_ids_non_cache
    all_members.select { |member| member unless member.is_active }.map(&:id)
  end

  def filter_members_from_list(member_ids)
    member_ids - filter_non_members_from_list(member_ids)
  end

  def filter_non_members_from_list(member_ids)
    member_ids - group_member_ids
  end

  def members
    member_visibility_from(cached_all_members.select { |member| member if member.is_active && !member.admin })
  end

  def admins
    member_visibility_from(cached_all_members.select { |member| member if member.admin })
  end

  def join_recently
    member_visibility_from(active_with_no_cache.sort_by(&:joined_at).reverse!).take(5)
  end

  def member_or_admin?(member)
    ids_include?(cached_all_members, member.id)
  end

  def member?(member)
    ids_include?(members, member.id)
  end

  def admin?(member)
    ids_include?(admins, member.id)  
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
end