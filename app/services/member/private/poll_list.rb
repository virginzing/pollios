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
    Poll.of_member_id(member.id).viewing_by_member(viewing_member)
  end

  def all_closed
    Poll.where("polls.member_id = #{member.id}").where("polls.close_status = 't'")
  end

  def all_voted
    Poll.unscoped.joins('inner join history_votes on polls.id = history_votes.poll_id')
      .where("history_votes.member_id = #{member.id}")
      .order('history_votes.created_at desc')
  end

  def all_bookmarked
    Poll.unscoped.joins('inner join bookmarks on polls.id = bookmarks.bookmarkable_id')
      .where("bookmarks.member_id = #{member.id}")
      .order('bookmarks.created_at desc')
  end

  def all_saved_vote_later
    Poll.unscoped.joins('inner join save_poll_laters on polls.id = save_poll_laters.savable_id')
      .where("save_poll_laters.member_id = #{member.id}")
      .order('save_poll_laters.created_at desc')
  end

  def saved_later_query(type_name)
    member.save_poll_laters.where(savable_type: type_name).map(&:savable_id)
  end

  def not_interested_query(type_name)
    member.not_interested_polls.where(unseeable_type: type_name).map(&:unseeable_id)
  end

end