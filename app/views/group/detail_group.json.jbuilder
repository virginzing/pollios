if @group.present?
  json.response_status "OK"

  json.group do
    json.partial! 'response_helper/group/full_info', group: @group
    json.viewing_member do
      json.is_member @group_member.active?(@member)
      json.is_pending @group_member.pending?(@member)
      json.is_requesting @group_member.requesting?(@member)
      json.is_admin @group_member.admin?(@member)
    end
  end

  json.member_group do
    json.active @member_active, partial: 'response_helper/group/member_group', as: :member
    # json.pending @member_pending, partial: 'response_helper/group/member_group', as: :member
    # json.request @member_request do |member|
    #   json.member_id member.id
    #   json.name member.get_name
    #   json.email member.email
    #   json.type member.member_type_text
    #   json.description member.get_description
    #   json.key_color member.get_key_color
    #   json.avatar member.get_avatar
    # end
  end
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end