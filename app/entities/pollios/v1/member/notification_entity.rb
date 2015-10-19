module Pollios::V1::Member
  class NotificationEntity < Grape::Entity
    expose :id, as: :notify_id
    expose :sender, if: -> (object, options) { is_not_anonymous_vote? }
    expose :message
    expose :custom_properties, as: :info

    def sender
      if object.sender.nil?
        Pollios::V1::Shared::MemberEntity.default_pollios_member
      elsif is_not_anonymous_vote?
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

    private
    def is_not_anonymous_vote?
      object.custom_properties[:anonymous] == false && object.custom_properties[:action] == "Vote"
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