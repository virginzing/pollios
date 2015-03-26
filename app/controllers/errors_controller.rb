class ErrorsController < ApplicationController
  layout false

  def show
    env_json = /.json/.match(env["REQUEST_PATH"]).present?

    @exception = env["action_dispatch.exception"]

    puts "exception => #{@exception}"

    if env_json
      render json: { response_status: "ERROR", error_code: request.path[1..-1], response_message: @exception.message }
    else
      render action: request.path[1..-1] 
    end
  end
end
