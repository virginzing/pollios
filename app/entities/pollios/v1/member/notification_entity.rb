module Pollios::V1::Member
  class NotificationEntity < Grape::Entity
    expose :id, as: :notification_id
    expose :sender
    expose :message
    expose :info
    expose :created_at

    def sender
      if object.sender.nil?
        Pollios::V1::Shared::MemberEntity.default_pollios_member
      elsif is_anonymous_vote?
      
      else
        Pollios::V1::Shared::MemberEntity.represent(object.sender)
      end
    end

    def message
      if type == "Poll"
        sender_name = object.sender.fullname
        if action == "Vote" || action == "Create"
          if is_anonymous?
            sender_name = "Anonymous"
          end

          if action == "Vote"
            action_message = "voted on"
          else
            action_message = "asked"
          end

          return "#{sender_name} #{action_message} \"#{poll_title}\""
        end

        return object.message
      else
        return object.message
      end
    end

    def info
      object.custom_properties.except(:worker, :notify, :friend_id, :member_id)
    end

    def created_at
      object.created_at.to_i
    end

    private
    def is_anonymous_vote?
      object.custom_properties[:anonymous] == true && object.custom_properties[:action] == "Vote"
    end

    def type
      object.custom_properties[:type]
    end

    def action
      object.custom_properties[:action]
    end

    def is_anonymous?
      object.custom_properties[:anonymous] == true
    end

    def poll_title
      object.custom_properties[:poll][:title]
    end
  end
end