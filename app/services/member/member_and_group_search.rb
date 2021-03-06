class Member::MemberAndGroupSearch

  attr_reader :member, :keyword, :index

  def initialize(member, keyword = nil, options = {})
    @member = member
    @index = options[:index] || 1

    first_or_create_search_keywords
    return unless keyword
    @keyword = keyword.downcase

    save_recent_keyword
  end

  def recent
    cached_recent_keywords
  end

  def members_searched
    search_members
  end

  def groups_searched
    search_groups
  end

  def first_5_members_searched
    search_members.limit(5)
  end

  def first_5_groups_searched
    search_groups.limit(5)
  end

  def members_by_page(_)
    members_searched.paginate(page: index)
  end

  def next_index(list)
    list.next_page || 0
  end

  def clear_searched_keywords
    recent_search = TypeSearch.find_by(member_id: member.id)
    recent_search.update!(search_users_and_groups: [])

    clear_searched_keywords_cached_for_member

    nil
  end

  def cached_recent_keywords
    Rails.cache.fetch("members/#{member.id}/searches/keywords") { recent_keywords }
  end

  private

  def first_or_create_search_keywords
    TypeSearch.create!(member_id: member.id) if TypeSearch.find_by(member_id: member.id).nil?
    clear_searched_keywords if TypeSearch.find_by(member_id: member.id).search_users_and_groups.nil?
  end

  def recent_keywords
    TypeSearch.find_by(member_id: member.id)[:search_users_and_groups].map { |tag| tag[:message] }.uniq[0..9]
  end

  def search_members
    Member.viewing_by_member(member)
      .with_status_account(:normal).where(first_signup: false, show_search: true)
      .where('LOWER(members.fullname) LIKE ? OR LOWER(members.public_id) = ?', "%#{keyword}%", keyword)
      .order_by_name
  end

  def search_groups
    Group.joins('LEFT OUTER JOIN group_members ON groups.id = group_members.group_id')
      .where("group_members.active = 't'")
      .group('groups.id')
      .select('groups.*, count(group_members.id) AS member_count')
      .where('LOWER(groups.name) LIKE ? OR LOWER(groups.public_id) = ?', "%#{keyword}%", keyword)
      .order('member_count desc, LOWER(groups.name)')
  end

  def save_recent_keyword
    recent_search = TypeSearch.find_by(member_id: member.id)
    recent_search = new_type_search unless recent_search.present?
    recent_search.update!(search_users_and_groups: []) unless recent_search.search_users_and_groups.present?
    recent_search.update!(search_users_and_groups: TypeSearch.find_by(member_id: member.id)[:search_users_and_groups] \
      .unshift(message: keyword, created_at: Time.now.utc))

    clear_searched_keywords_cached_for_member
  end

  def clear_searched_keywords_cached_for_member
    FlushCached::Member.new(member).clear_list_searched_keywords
  end

  def new_type_search
    TypeSearch.create!(search_tags: [], search_users_and_groups: [], member_id: member.id) 
  end

end