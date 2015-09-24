# TODO: Complete This. Along with Test spec!!!!!
# NOT USE CURRENTLY

class Group::Service
    def initialize(group, options={})
        @group = group
        @options = options
    end

    def is_admin_of_group?(member_id)
        return GroupMember.find_by(group_id: @group.id, member_id: member_id).is_master
    end

    # # service = GroupService.new(@current_member, @current_gorup).invite_users(users)
    # def invite_members(invitee_id_list)
    #     group_id = @group.id
    #     member_id = @member.id

    #     filtered_invitee_ids = filter_only_new_member(invitee_id_list)

    # end

    # private


    # def filter_only_new_member(invitee_list)
    #     return invitee_list - @group.group_members.map(&:member_id)
    # end



end