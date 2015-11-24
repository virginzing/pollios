count = 0
json.groups @posted_in_groups do |group|

    group_member = Group::MemberList.new(group)
    is_active_member = group_member.active?(@member)
    is_pending = group_member.pending?(@member)
    is_requesting = group_member.requesting?(@member)
    is_admin = group_member.admin?(@member)

    if group.public || is_pending || is_active_member
        json.partial! 'response_helper/group/default', group: group
        json.member_count group.get_member_count

        json.viewing_member do
            json.is_member is_active_member
            json.is_pending is_pending
            json.is_requesting is_requesting
            json.is_admin is_admin
        end

        count += 1
    end
end

json.count count