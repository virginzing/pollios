class JoinGroupWorker
  include Sidekiq::Worker
  include SymbolHash

  sidekiq_options unique: true

  def perform(member_id, group_id, custom_data = nil)
    member = Member.cached_find(member_id)
    group = Group.cached_find(group_id)

    @group_nofication = AskJoinGroup.new(member, group)

    recipient_ids = @group_nofication.recipient_ids

    find_recipient ||= Member.where(id: recipient_ids).uniq

    @count_notification = CountNotification.new(find_recipient)

    device_ids ||= @count_notification.device_ids

    member_ids ||= @count_notification.member_ids

    hash_list_member_badge ||= @count_notification.hash_list_member_badge

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
      @notf.alert = @group_nofication.custom_message
      @notf.sound = true
      @notf.custom_properties = apn_custom_properties
      @notf.save!
    end

    find_recipient.each do |member_receive|
      hash_custom = {
        action: ACTION[:join],
        group: GroupNotifySerializer.new(group).as_json(),
        notify: hash_list_member_badge[member_receive.id],
        worker: WORKER[:join_group]
      }

      NotifyLog.create!(sender_id: member.id, recipient_id: member_receive.id, message: @group_nofication.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
    end

    Apn::App.first.send_notifications
  rescue => e
    puts "JoinGroupWorker => #{e.message}"
  end
end