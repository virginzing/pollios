class InviteFriendToGroupWorker
  include Sidekiq::Worker
  include SymbolHash

  sidekiq_options unique: true

  def perform(member_id, friend_ids, group_id, custom_data = {})
    member = Member.find_by(id: member_id)
    group = Group.find_by(id: group_id)

    raise ArgumentError.new(ExceptionHandler::Message::Group::NOT_FOUND) if group.nil?
    raise ArgumentError.new(ExceptionHandler::Message::Member::NOT_FOUND) if member.nil?

    member_id = custom_data["sender_id"] || member.id

    @invite_group = InviteGroup.new(member_id, friend_ids, group)

    recipient_ids = @invite_group.recipient_ids

    find_recipient ||= Member.where(id: recipient_ids)

    receive_notification ||= Member.where(id: @invite_group.receive_notification).uniq

    @count_notification = CountNotification.new(receive_notification)

    device_ids ||= @count_notification.device_ids

    member_ids ||= @count_notification.member_ids

    hash_list_member_badge ||= @count_notification.hash_list_member_badge

    hash_list_member_request_count ||= @count_notification.hash_list_member_request_count

    @custom_properties = {
      type: TYPE[:group],
      group_id: group.id
    }

    device_ids.each_with_index do |device_id, index|
      apn_custom_properties = {
        type: TYPE[:group],
        group_id: group.id,
        notify: hash_list_member_badge[member_ids[index]]
      }

      @notf = Apn::Notification.new
      @notf.device_id = device_id
      @notf.badge = hash_list_member_badge[member_ids[index]]
      @notf.alert = @invite_group.custom_message
      @notf.sound = true
      @notf.custom_properties = apn_custom_properties
      @notf.save!
    end

    find_recipient.each do |member|
      hash_custom = {
        action: ACTION[:invite],
        group: GroupNotifySerializer.new(group).as_json,
        notify: hash_list_member_badge[member.id],
        worker: WORKER[:invite_friend_to_group]
      }

      NotifyLog.create!(sender_id: member_id, recipient_id: member.id, message: @invite_group.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
    end

    Apn::App.first.send_notifications
  rescue => e
    puts "InviteFriendToGroupWorker => #{e.message}"
  end
end
