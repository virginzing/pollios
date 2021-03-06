module Pollios::V1::CurrentMemberAPI
  class NotificationEntity < Pollios::V1::BaseEntity
    expose :id, as: :notification_id
    expose :sender
    expose :message
    expose :info

    with_options(format_with: :as_integer) do
      expose :created_at
    end

    private
    def sender
      return Pollios::V1::Shared::MemberEntity.default_pollios_member if object.sender.nil? && action != 'Invite'
      return GroupForNotificationEntity.represent(group) if object.sender.nil? && action == 'Invite'
      return nil if voted_as_anonymous?
      Pollios::V1::Shared::MemberEntity.represent(object.sender)
    end

    def message
      return poll_message if type == 'Poll'
      return comment_message if type == 'Comment'
      object.message
    end

    def poll_message
      return "#{sender_name} #{poll_action} \"#{poll_title}\"" if voted_or_asked?
      object.message
    end

    def comment_message
      "#{sender_name} #{comment_action}"
    end

    def poll_action
      return 'voted on' if action == 'Vote'
      'asked'
    end

    def comment_action
      return "commented in  \"#{poll_title}\"" if action == 'Comment'
      'mentioned you in a comment'
    end

    def sender_name
      return 'Anonymous' if voted_as_anonymous?
      object.sender.fullname
    end

    def info
      object.custom_properties.except(:worker, :notify, :friend_id, :member_id)
    end

    def voted_or_asked?
      action == 'Vote' || action == 'Create'
    end

    def voted_as_anonymous?
      object.custom_properties[:anonymous] == true && object.custom_properties[:action] == 'Vote'
    end

    def type
      object.custom_properties[:type]
    end

    def action
      object.custom_properties[:action]
    end

    def as_anonymous?
      object.custom_properties[:anonymous] == true
    end

    def poll_title
      object.custom_properties[:poll][:title]
    end

    def group
      Group.cached_find(object.custom_properties[:group_id])
    end
  end
end