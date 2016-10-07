module V1::Auth
  class GetController < V1::ApplicationController
    before_action :must_signed_in, only: [:sign_out]

    def sign_out
      remove_member_session

      redirect_to :back
    end

    private

    def must_signed_in
      redirect_to '/' unless member_signed_in?
    end

    def remove_member_session
      session[:member_id] = nil
    end
  end
end
