class Request::Search

  PER_PAGE = 50

  def initialize(member, params)
    @member = member
    @params = params

    @init_list_group = Member::ListGroup.new(@member)
    @init_list_friend = Member::ListFriend.new(@member)
  end

  def search
    @params[:search]
  end

  def next_cursor
    @params[:next_cursor] || 0
  end

  def my_group_active
    @my_group_active ||= @init_list_group.active
  end

  def my_friend_active
    @my_friend_active ||= @init_list_friend.active
  end

  def my_friend_block
    @my_friend_block ||= @init_list_friend.block
  end

  def list_groups
    @list_groups ||= groups
  end

  def list_members
    @list_members ||= members
  end
  
  
  private


  def groups
    groups = Group.where("groups.name LIKE ? OR groups.public_id LIKE ?", "%#{search}%", "%#{search}%").order("name asc")
    groups = groups.paginate(per_page: PER_PAGE, page: next_cursor)
  end

  def members
    block_friend = my_friend_block.map(&:id)

    members = Member.unscoped.where("members.fullname LIKE ? OR members.public_id LIKE ?", "%#{search}%", "%#{search}%").order("fullname asc")
    members = members.where("members.id NOT IN (?)", block_friend) if block_friend.count > 0
    members = members.paginate(per_page: PER_PAGE, page: next_cursor)
  end

end