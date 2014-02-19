class GuestsController < ApplicationController

  def try_out
    @guests = Guest.try_out_app(guests_params)
  end

  private

  def guests_params
    params.permit(:udid)
  end
end
