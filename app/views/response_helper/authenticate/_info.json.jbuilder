json.partial! 'response_helper/member/full_info'

if member.company?
  json.list_group member.company.groups do |group|
    json.partial! 'response_helper/group/full_info', group: group
  end
end

json.roles member.get_roles
