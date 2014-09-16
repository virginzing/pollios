class CreateGroupCompany
  def initialize(member, company, group_params, list_member_ids)
    @member = member
    @company = company
    @group_params = group_params
    @list_member_ids = list_member_ids
  end

  def new_list_member_ids
    @list_member_ids.split(",").collect{|e| e.to_i }
  end

  def new_list_members_count
    new_list_member_ids.count
  end

  def create_group
    Group.transaction do
      begin
        @group = Group.new(@group_params)
        @group.leave_group = false
        @group.member_count = new_list_members_count
        @group.save!
      end

      if @group.present?
        @company.group_companies.create!(group_id: @group.id)
        if new_list_members_count > 0
          add_member_to_group
        end
      end
      @group
    end
  end

  private

  def add_member_to_group
    new_list_member_ids.each do |member_id|
      GroupMember.create!(member_id: member_id, group_id: @group.id, is_master: false, active: true, notification: true)
      Rails.cache.delete([member_id, 'group_active'])
    end
  end

end
