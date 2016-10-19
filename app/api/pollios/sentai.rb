module Pollios
  class Sentai < Grape::API
    format :json
    prefix :sentai

    rescue_from ExceptionHandler::UnprocessableEntity do |e|
      e = eval(e.message)
      error!(e[:message], e[:status])
    end

    helpers do
      def current_member
        @current_member ||= authenticate_member
      end

      def authenticate_member
        member = member_if_allowed
        authen_token = headers['X-Api-Key']
        error!('401 Unauthorized: no token', 401) unless authen_token.present?

        member_access_token = member.api_tokens.where('token = ?', authen_token)
        error!('401 Unauthorized: invalid token', 401) unless member_access_token.present?

        member
      end

      def member_if_allowed
        member = Member.find_by(id: params[:member_id])
        error!('404 Member not found', 404) if member.nil?
        error!('403 Forbidden', 403) if member.blacklist? || member.ban?
        member
      end
    end

    mount Auth::App
  end
end
