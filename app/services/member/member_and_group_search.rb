class Member::MemberAndGroupSearch

  attr_reader :member, :keyword

  def initialize(member, keyword = nil)
    @member = member

    return unless keyword
    @keyword = keyword.downcase

    save_recent_keyword
  end

  def recent
    recent_keywords
  end

  def members_searched
    search_members
  end

  def groups_searched
    search_groups
  end

  def recent_keywords
    TypeSearch.find_by(member_id: member.id)[:search_users_and_groups].map { |tag| tag[:message] }.uniq[0..9]
  end

  def search_members
    Member.viewing_by_member(member)
      .with_status_account(:normal).where(first_signup: false, show_search: true)
      .where('LOWER(members.fullname) LIKE ? OR LOWER(members.public_id) = ?', "%#{keyword}%", "%#{keyword}%")
      .order_by_name
  end

  def search_groups
    Group.joins('LEFT OUTER JOIN group_members ON groups.id = group_members.group_id')
      .where("group_members.active = 't'")
      .group('groups.id')
      .select('groups.*, count(group_members.id) AS member_count')
      .where('LOWER(groups.name) LIKE ? OR LOWER(groups.public_id) = ?', "%#{keyword}%", "%#{keyword}%")
      .order('member_count desc, LOWER(groups.name)')
  end

  def save_recent_keyword
    recent_search = TypeSearch.find_by(member_id: member.id)
    recent_search.update!(search_users_and_groups: TypeSearch.find_by(member_id: member.id)[:search_users_and_groups] \
      .unshift(message: keyword, created_at: Time.now.utc))
  end

end