class Member::PollSearch

  attr_reader :member, :hashtag, :index

  def initialize(member, hashtag = nil, options = {})
    @member = member
    @index = options[:index] || 1

    first_or_create_search_tag
    return unless hashtag
    @hashtag = hashtag.downcase

    save_recent_tag
  end

  def recent
    cached_recent_tags
  end

  def popular
    popular_tags.limit(10).map(&:name)
  end

  def polls_searched
    search_polls
  end

  def clear_searched_tags
    recent_search = TypeSearch.find_by(member_id: member.id)
    recent_search.update!(search_tags: [])

    clear_searched_tags_cached_for_member
  
    nil
  end

  def polls_by_page(list)
    list.paginate(page: index)
  end

  def next_index(_)
    polls_searched.next_page || 0
  end

  def cached_recent_tags
    Rails.cache.fetch("members/#{member.id}/searches/tags") { recent_tags }
  end

  private

  def first_or_create_search_tag
    TypeSearch.create!(member_id: member.id) if TypeSearch.find_by(member_id: member.id).nil?
    clear_searched_tags if TypeSearch.find_by(member_id: member.id).search_tags.nil?
  end

  def recent_tags
    TypeSearch.find_by(member_id: member.id)[:search_tags].map { |tag| tag[:message] }.uniq[0..9]
  end

  def popular_tags
    Tag.joins(:polls).merge(Poll.unscoped.viewing_by_member(member).active_poll.have_vote.without_closed.except_series)
      .select('tags.*, count(taggings.tag_id) as tag_count')
      .select('tags.*, max(taggings.created_at) AS tagged_at')
      .group('tags.id')
      .order('tag_count desc, tagged_at desc')
  end

  def search_polls
    Poll.viewing_by_member(member)
      .joins('LEFT OUTER JOIN taggings ON polls.id = taggings.poll_id')
      .joins('LEFT OUTER JOIN tags ON taggings.tag_id = tags.id')
      .where('LOWER(tags.name) = (?)', hashtag)
      .paginate(page: index)
  end

  def save_recent_tag
    recent_search = TypeSearch.find_by(member_id: member.id)
    recent_search = new_type_search unless recent_search.present?
    recent_search.update!(search_tags: []) unless recent_search.search_tags.present?
    recent_search.update!(search_tags: TypeSearch.find_by(member_id: member.id)[:search_tags] \
      .unshift(message: hashtag, created_at: Time.now.utc))

    clear_searched_tags_cached_for_member
  end

  def clear_searched_tags_cached_for_member
    FlushCached::Member.new(member).clear_list_searched_tags
  end

  def new_type_search
    TypeSearch.create!(search_tags: [], search_users_and_groups: [], member_id: member.id) 
  end

end