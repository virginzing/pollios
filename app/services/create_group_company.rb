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
        @group.group_type = :company
        @group.cover_preset = @group_params[:cover].present? ? "0" : rand(1..26)
        @group.member_count = new_list_members_count
        @group.save!
      end

      if @group.present?
        @company.group_companies.create!(group_id: @group.id)
        if new_list_members_count > 0
          add_member_to_group
        end
        AddMemberToGroupWorker.perform_async(new_list_member_ids, @group.id, @member.id)
      end
      @group
    end
  end

  private

  def add_member_to_group
    Member.where(id: new_list_member_ids).each do |member|
      GroupMember.create!(member_id: member.id, group_id: @group.id, is_master: false, active: true, notification: true)
      CompanyMember.add_member_to_company(member, @company)
      Company::TrackActivityFeedGroup.new(member, @group, "join").tracking
      # Rails.cache.delete([member.id, 'group_active'])
      FlushCached::Member.new(member).clear_list_groups
    end
  end

end
