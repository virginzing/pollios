class PromoteAdminWorker
  include Sidekiq::Worker
  include SymbolHash

  sidekiq_options unique: true
  
  def perform(promoter_id, promotee_id, group_id)
    promoter = Member.cached_find(promoter_id)

    promotee = Member.cached_find(promotee_id)

    group = Group.cached_find(group_id)

    @apn_promote_admin = Apn::PromoteAdmin.new(promoter, promotee, group)

    recipient_ids = @apn_promote_admin.recipient_ids

    find_recipient_notify ||= Member.where(id: recipient_ids).uniq

    @count_notification = CountNotification.new(find_recipient_notify)

    hash_list_member_badge ||= @count_notification.hash_list_member_badge

    @custom_properties = {
      type: TYPE[:group],
      group_id: group.id,
      action: TYPE[:promote_admin]
    }

    find_recipient_notify.each_with_index do |member, index|
      member.apn_devices.each do |device|
        apn_custom_properties = {
          type: TYPE[:group],
          group_id: group.id,
          notify: hash_list_member_badge[member.id] || 0
        }

        @notf = Apn::Notification.new
        @notf.device_id = device.id
        @notf.badge = hash_list_member_badge[member.id]
        @notf.alert = @apn_promote_admin.custom_message
        @notf.sound = true
        @notf.custom_properties = apn_custom_properties
        @notf.save!
      end
    end

    find_recipient_notify.each do |member|

      hash_custom = {
        notify: hash_list_member_badge[member.id] || 0
      }

      NotifyLog.create!(sender_id: promoter.id, recipient_id: member.id, message: @apn_promote_admin.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
    end

    Apn::App.first.send_notifications
  rescue => e
    puts "PromoteAdminWorker => #{e.message}"
  end
end