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
    new_list_member_ids.size
  end

  def create_group
    Group.transaction do
      begin
        @group = Group.new(@group_params)
        @group.member = @member
        @group.group_type = @group.public ? :normal : :company
        @group.need_approve = @group_params["need_approve"].to_b
        @group.opened = @group_params["opened"].to_b
        @group.save!
      end

      if @group.present?
        @company.group_companies.create!(group_id: @group.id)
        add_default_creator_to_group
        if new_list_members_count > 0
          add_member_to_group
        end
        AddMemberToGroupWorker.perform_async(new_list_member_ids, @group.id, @member.id)
      end
      @group
    end
  end

  private

  def add_default_creator_to_group
    @group.group_members.create!(member: @member, active: true, is_master: true, notification: true)
  end

  def add_member_to_group
    Member.where(id: new_list_member_ids).each do |member|
      GroupMember.create!(member_id: member.id, group_id: @group.id, is_master: false, active: true, notification: true)
      CompanyMember.add_member_to_company(member, @company)
      FlushCached::Member.new(member).clear_list_groups
    end

  end

end
