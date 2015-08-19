class MessagesController < ApplicationController

    layout 'admin'
    before_filter :authenticate_admin!

    def index
        @message_logs = MessageLog.all
    end

    def new
        @message = MessageLog.new
    end

    def create
        init = System::Message.new(message_params, current_admin.id)
        message_log = init.create_message_log

        if message_log
            AllMessageWorker.perform_async(message_log.id)
            flash[:success] = "Send message success"
            redirect_to messages_path
        else
            flash[:error] = "Something went wrong"
            redirect_to new_message_path
        end
    end

    private

    def message_params
        params.require(:message_log).permit(:list_member, :message)    
    end
end
