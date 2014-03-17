if @group.present?
  json.response_status "OK"
  json.group do
    json.partial! 'group/detail', group: @group
  end
  json.pending @group , partial: 'members/detail', as: :member
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end