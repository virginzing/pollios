class BookmarkPoll
  def initialize(params)
    @params = params
  end

  def member_id
    @params[:member_id]
  end

  def get_list_questionnaire_id
    query_bookmark_poll.select{|e| e if e.bookmarkable_type == "PollSeries" }.map(&:bookmarkable_id)
  end

  def get_list_poll_id
    query_bookmark_poll.select{|e| e if e.bookmarkable_type == "Poll" }.map(&:bookmarkable_id)
  end

  private

  def query_bookmark_poll
    @query ||= Bookmark.where(member_id: member_id)
  end

end