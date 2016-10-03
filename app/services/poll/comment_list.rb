class Poll::CommentList
  include Poll::Private::CommentList

  attr_reader :poll, :viewing_member, :index

  def initialize(poll, options = {})
    @poll = poll

    @viewing_member = options[:viewing_member]
    @index = options[:index] || 1

    can_view, message = can_view?
    fail ExceptionHandler::UnprocessableEntity, message unless can_view
  end

  def comments
    comment_visibility
  end

  def comments_by_page
    comment_visibility.paginate(page: index)
  end

  def sort_comments_by_page
    comments_by_page.sort_by(&:created_at)
  end

  def next_index
    comments_by_page.next_page || 0
  end

  def comment_count
    comments.count
  end

end