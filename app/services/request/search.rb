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

  def next_member
    @params[:next_cursor_member] || 1
  end

  def next_group
    @params[:next_cursor_group] || 1
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

  def check_is_friend
    @init_list_friend.check_is_friend
  end

  # groups #

  def list_groups
    @list_groups ||= groups
  end

  def next_cursor_group
    list_groups.next_page.nil? ? 0 : list_groups.next_page
  end

  def total_list_groups
    list_groups.total_entries
  end

  # members #

  def list_members
    @list_members ||= members
  end

  def next_cursor_member
    list_members.next_page.nil? ? 0 : list_members.next_page
  end

  def total_list_members
    list_members.total_entries
  end
  
  
  private


  def groups
    groups = Group.joins(:group_members_active).select("groups.*, count(group_members.member_id) as amount_member")
                  .group("groups.id")
                  .where("(groups.name LIKE ? AND groups.public = 't') OR (groups.public_id LIKE ? AND groups.public = 't')", "%#{search}%", "%#{search}%")
                  .order("name asc")

    groups = groups.paginate(per_page: PER_PAGE, page: next_group)
  end

  def members
    block_friend = my_friend_block.map(&:id)

    members = Member.unscoped.without_member_type(:company).where("members.fullname LIKE ? OR members.public_id LIKE ?", "%#{search}%", "%#{search}%").order("fullname asc")
    members = members.where("members.id NOT IN (?)", block_friend) if block_friend.count > 0
    members = members.paginate(per_page: PER_PAGE, page: next_member)
  end

end