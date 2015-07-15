if @all_request_groups
  json.response_status "OK"

  json.groups @all_request_groups do |group|
    if group.members_request.size > 0
      json.partial! 'response_helper/group/default', group: group

      json.request group.members_request do |member|
        json.partial! 'response_helper/member/short_info_feed', member: member
      end
    end
  end
end
