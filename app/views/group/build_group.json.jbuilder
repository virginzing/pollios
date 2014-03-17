if @group.present?
  json.response_status "OK"
  json.group do
    json.partial! 'group/detail', group: @group
  end
  json.member_group do
    json.active @group.get_member_active, partial: 'members/detail', as: :member
    json.pending @group.get_member_inactive, partial: 'members/detail', as: :member
  end
else
  json.response_status "ERROR"
  json.response_message "Unable.."
end
