class Group::MemberList
  include Group::Private::MemberList

  attr_reader :group, :viewing_member, :visible_member_list

  def initialize(group, options = {})
    @group = group

    return unless options[:viewing_member]

    @viewing_member = options[:viewing_member]
    @visible_member_list = Member.viewing_by_member(viewing_member)
  end

  def all
    cached_all_members
      .select(&method(:active?))
  end

  def active
    cached_all_members
      .select(&method(:active?))
      .select(&method(:visible?))
      .sort_by(&method(:downcased_fullname))
  end

  def active_with_no_cache
    queried_all_members
      .select(&method(:active?))
      .select(&method(:visible?))
      .sort_by(&method(:downcased_fullname))
  end

  def pending
    cached_all_members
      .reject(&method(:active?))
      .reject(&method(:requesting?))
      .select(&method(:visible?))
      .sort_by(&method(:downcased_fullname))
  end

  def requesting
    cached_all_requests
  end

  def members
    cached_all_members
      .select(&method(:active?))
      .reject(&method(:admin?))
      .select(&method(:visible?))
      .sort_by(&method(:downcased_fullname))
  end

  def admins
    cached_all_members
      .select(&method(:admin?))
      .select(&method(:visible?))
      .sort_by(&method(:downcased_fullname))
  end

  def join_recently
    queried_all_members
      .select(&method(:active?))
      .select(&method(:visible?))
      .sort_by(&method(:duration_since_joined))
      .take(5)
  end

  # for testing and emergency only
  def pending_ids_non_cache
    queried_all_members
      .reject(&method(:active?))
      .map(&:id)
  end

  def filter_members_from_list(member_ids)
    member_ids - filter_non_members_from_list(member_ids)
  end

  def filter_non_members_from_list(member_ids)
    member_ids - group_member_ids
  end

  def raise_error_not_member(member)
    fail ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Group::NOT_IN_GROUP unless active.include?(member)
  end

  def raise_error_not_admin(member)
    fail ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Group::NOT_ADMIN unless admin?(member)
  end
end
