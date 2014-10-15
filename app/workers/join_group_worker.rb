class JoinGroupWorker
  include Sidekiq::Worker
  include SymbolHash

  def perform(member_id, group_id, custom_data = nil)
    begin
      member = Member.find(member_id)
      group = Group.find(group_id)

      @group_nofication = AskJoinGroup.new(member, group, nil, "join")

      recipient_ids = @group_nofication.recipient_ids

      find_recipient ||= Member.where(id: recipient_ids)

      @count_notification = CountNotification.new(find_recipient)

      device_ids ||= @count_notification.device_ids

      member_ids ||= @count_notification.member_ids

      hash_list_member_badge ||= @count_notification.hash_list_member_badge

      @custom_properties = {
        type: TYPE[:group],
        group_id: group.id
      }

      device_ids.each_with_index do |device_id, index|
        @notf = Apn::Notification.new
        @notf.device_id = device_id
        @notf.badge = hash_list_member_badge[member_ids[index]]
        @notf.alert = @group_nofication.custom_message
        @notf.sound = true
        @notf.custom_properties = @custom_properties
        @notf.save!
      end

      find_recipient.each do |member_receive|
        hash_custom = {
          action: ACTION[:join],
          group: group.as_json(),
          notification_count: hash_list_member_badge[member_receive.id]
        }

        NotifyLog.create(sender_id: member.id, recipient_id: member_receive.id, message: @group_nofication.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
      end

      Apn::App.first.send_notifications
    rescue => e
      puts "JoinGroupWorker => #{e.message}"
    end
  end

end
