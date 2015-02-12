class AddMemberToGroupWorker
  include Sidekiq::Worker
  include SymbolHash

  sidekiq_options unique: true

  def perform(list_members, group_id, member_id, custom_data = nil)
    begin
      @list_members = list_members
      group = Group.cached_find(group_id)
      member = Member.cached_find(member_id)

      @member_to_group = Company::MemberToGroup.new(@list_members, group)

      recipient_ids = @member_to_group.recipient_ids

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
          notify: hash_list_member_badge[member_ids[index]],
        }

        @notf = Apn::Notification.new
        @notf.device_id = device_id
        @notf.badge = hash_list_member_badge[member_ids[index]]
        @notf.alert = @member_to_group.custom_message
        @notf.sound = true
        @notf.custom_properties = apn_custom_properties
        @notf.save!
      end

      find_recipient.each do |member_receive|
        hash_custom = {
          action: ACTION[:join],
          group: GroupNotifySerializer.new(group).as_json(),
          notify: hash_list_member_badge[member_receive.id]
        }

        NotifyLog.create!(sender_id: member.id, recipient_id: member_receive.id, message: @member_to_group.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
      end

      Apn::App.first.send_notifications
    rescue => e
      puts "AddMemberToGroupWorker => #{e.message}"
    end
  end
  
end