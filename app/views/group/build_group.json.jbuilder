if @group.present?
  json.response_status "OK"
  json.group do
    json.partial! 'group/detail', group: @group
  end
  json.member_active @group.get_member_active, partial: 'members/detail', as: :member
  json.member_inactive @group.get_member_inactive, partial: 'members/detail', as: :member
else
  json.response_status "ERROR"
  json.response_message "Unable.."
end
