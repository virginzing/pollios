count = 0
json.groups @posted_in_groups do |group|

    group_member = Group::ListMember.new(group)
    is_active_member = group_member.is_active?(@member)
    is_pending = group_member.is_pending?(@member)
    is_requesting = group_member.is_requesting?(@member)

    if group.public || is_pending || is_active_member
        json.partial! 'response_helper/group/default', group: group
        json.member_count group.get_member_count

        json.is_member is_active_member
        json.is_pending is_pending
        json.is_requesting is_requesting
        count += 1
    end
end

json.count count