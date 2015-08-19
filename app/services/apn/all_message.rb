class Apn::AllMessage
    include SymbolHash
    include ActionView::Helpers::TextHelper
    include NotificationsHelper

    def initialize(message_log)
        @message_log = message_log
    end

    def recipient_ids
        @message_log.list_member
    end

    def custom_message
        message = "You got message \"#{@message_log.message}\""
        truncate_message(message)
    end
end