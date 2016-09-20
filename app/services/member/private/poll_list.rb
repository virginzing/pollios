module Member::Private::PollList

  # private

  def ids_for(list)
    list.map(&:id)
  end

  def ids_include?(list, id)
    ids_for(list).include?(id)
  end

  def member_report_polls
    member.poll_reports.to_a
  end

  def member_report_commments
    member.comment_reports.to_a  
  end

  def member_history_viewed_polls
    member.history_views.map(&:poll_id)
  end

  def member_watched_polls
    member.watcheds.where(poll_notify: true, comment_notify: true)
  end

  def member_voted_all_polls
    Poll.joins(history_votes: :choice)
      .select('polls.*, history_votes.choice_id as choice_id')
      .where("(history_votes.member_id = #{member.id} " \
        'AND history_votes.poll_series_id = 0)' \
        "OR (history_votes.member_id = #{member.id} " \
        'AND history_votes.poll_series_id != 0 AND polls.order_poll = 1)')
      .collect! do |poll| 
        Hash[
          poll_id: poll.id, 
          choice_id: poll.choice_id, 
          poll_series_id: poll.poll_series_id, 
          show_result: poll.show_result, 
          system_poll: poll.system_poll
        ]
      end
      .to_a
  end

  def all_created
    Poll.viewing_by_member(viewing_member).where('polls.member_id = ?', member.id)
  end

  def all_closed
    Poll.where("polls.member_id = #{member.id}").where("polls.close_status = 't'")
  end

  def all_voted
    Poll.unscoped.viewing_by_member(viewing_member)
      .joins('LEFT OUTER JOIN history_votes ON polls.id = history_votes.poll_id')
      .where.not("polls.member_id = #{member.id}")
      .where("history_votes.member_id = #{member.id}")
      .select('polls.*, history_votes.created_at AS voted_at')
      .order('voted_at DESC')
  end

  def all_bookmarked
    Poll.unscoped.joins('LEFT OUTER JOIN bookmarks ON polls.id = bookmarks.bookmarkable_id')
      .where("bookmarks.member_id = #{member.id}")
      .order('bookmarks.created_at DESC')
  end

  def all_saved_vote_later
    Poll.unscoped.joins('LEFT OUTER JOIN save_poll_laters ON polls.id = save_poll_laters.savable_id')
      .where("save_poll_laters.member_id = #{member.id}")
      .order('save_poll_laters.created_at DESC')
  end

  def public_activity(limit)
    (all_voted.where('polls.public = true')
      .select("polls .*, history_votes.created_at AS activity_at, 'Vote' AS action")
      .limit(limit) | \
      all_created.where('polls.public = true')
        .select("polls .*, polls.created_at AS activity_at, 'Create' AS action")
        .limit(limit))
      .sort_by(&:activity_at)
      .reverse!
      .take(limit)
  end

  def saved_later_query(type_name)
    member.save_poll_laters.where(savable_type: type_name).map(&:savable_id)
  end

  def not_interested_query(type_name)
    member.not_interested_polls.where(unseeable_type: type_name).map(&:unseeable_id)
  end

  def next_page_index(list)
    list.next_page.nil? ? 0 : list.next_page
  end

end