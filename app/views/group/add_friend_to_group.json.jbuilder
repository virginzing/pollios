if @group.present?
  json.response_status "OK"
  json.group do
    json.partial! 'response_helper/group/full_info', group: @group
end

json.member_group do
    count = 0
    json.pending @group.get_member_inactive do |member|
        json.partial! 'response_helper/member/short_info', member: member
        json.status @is_friend[count]
        count += 1
    end
end

else
  json.response_status "ERROR"
  json.response_message "This member was invited in group already."
end
