json.count @posted_in_groups.count
json.groups @posted_in_groups do |group|
    json.partial! 'response_helper/group/default', group: group
    json.member_count group.get_member_count
    
    group_member = Group::ListMember.new(group)
    json.is_member group_member.is_active?(@member)
    json.is_pending group_member.is_pending?(@member)
    json.is_requesting group_member.is_requesting?(@member)
end