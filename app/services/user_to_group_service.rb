class UserToGroupService

  def initialize(params)
    @group_id = params[:group_id]
    @fullname = params[:fullname]
    @member_id = params[:member_id]
  end

  def users
    if @fullname.present? & @group_id.present?
      query = Member.where("lower(fullname) LIKE ?", "%#{@fullname.downcase}%")
      query = query.where("id NOT IN (?)", members_in_group_active.map(&:id)) if members_in_group_active.size > 0
      query
    end
  end

  def add!
    Group.transaction do
      unless members_in_group_active.map(&:id).include?(@member_id)
        find_group.group_members.create!(member: find_member, is_master: false, active: true)
        clear_all_cached!
        true
      else
        false
      end
    end
  end

  def error_message
    "#{find_member.get_name} has already joined the #{find_group.name}."
  end

  private

  def find_group
    Group.cached_find(@group_id)
  end

  def find_member
    Member.cached_find(@member_id) if @member_id
  end

  def members_in_group_active
    init = Group::MemberList.new(find_group)
    init.active
  end

  def clear_all_cached!
    FlushCached::Member.new(find_member).clear_list_groups
    FlushCached::Group.new(find_group).clear_list_members
  end

end
