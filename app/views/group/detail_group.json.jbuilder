if @group.present?
  json.response_status "OK"
  json.group do
    json.partial! 'response_helper/group/full_info', group: @group
  end
  json.member do
    json.admin @is_admin
  end
  json.member_group do
    json.active @member_active, partial: 'response_helper/group/member_group', as: :member
    json.pending @member_pendding, partial: 'response_helper/group/member_group', as: :member
    json.request @member_request do |member|
      json.member_id member.id
      json.name member.get_name
      json.email member.email
      json.type member.member_type_text
      json.description member.get_description
      json.avatar member.get_avatar
    end
  end
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end