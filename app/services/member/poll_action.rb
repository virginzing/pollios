class Member::PollAction

  attr_reader :member, :poll

  def initialize(member, poll = nil, options = {})
    @member = member
    @poll = poll
    @options = options
  end

  def view
    create_poll_viewing_record
  end

  private

  def create_poll_viewing_record
    return if HistoryView.exists?(member_id: member.id, poll_id: poll.id)

    poll.reload

    HistoryView.transaction do
      HistoryView.create! member_id: member.id, poll_id: poll.id
      create_company_group_action_tracking_record_for_action('view')

      poll.with_lock do
        poll.view_all += 1
        poll.save!
      end

      FlushCached::Member.new(member).clear_list_history_viewed_polls
    end
  end

  def create_company_group_action_tracking_record_for_action(action)
    return unless poll.in_group

    group_ids = poll.in_group_ids.split(',').map(&:to_i)
    group_ids.each do |group_id|
      member.activity_feed.create! action: action, trackable: poll, group_id: group_id
    end
  end
end