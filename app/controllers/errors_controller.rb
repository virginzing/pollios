class ErrorsController < ApplicationController
  layout false
  def show
    @exception = env["action_dispatch.exception"]
    render action: request.path[1..-1]
  end
end
