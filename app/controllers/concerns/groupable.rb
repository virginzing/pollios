module Groupable

  def list_groups
    return unless @current_member.present?
    init_list_groups = Member::GroupList.new(@current_member)
    @group_by_name = Hash[init_list_groups.active.map { |group| [group.id, GroupDetailSerializer.new(group).as_json] }]
  end

end
