class System::Message
    def initialize(params, admin_id)
        @params = params
        @admin_id = admin_id
    end

    def list_member
        @params["list_member"].split(",").map(&:to_i)
    end

    def create_message_log
        MessageLog.create!(admin_id: @admin_id, message: @params["message"], list_member: list_member)
    end
end