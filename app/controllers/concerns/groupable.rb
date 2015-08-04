module Groupable

  def list_groups
    return unless @current_member.present?
    init_list_groups = Member::ListGroup.new(@current_member)
    @group_by_name = Hash[init_list_groups.active.map { |f| [f.id, Hash['id' => f.id, 'name' => f.name, 'photo' => f.get_photo_group]] }]
  end

end
