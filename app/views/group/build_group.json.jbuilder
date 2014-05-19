if @group.present?
  json.response_status "OK"
  json.group do
    json.partial! 'response_helper/group/full_info', group: @group
  end
  json.member_group do
    json.active @group.get_member_active, partial: 'response_helper/member/short_info', as: :member
    json.pending @group.get_member_inactive, partial: 'response_helper/member/short_info', as: :member
  end
else
  json.response_status "ERROR"
  json.response_message "Unable.."
end
