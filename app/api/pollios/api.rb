module Pollios
  class API < Grape::API
    format :json
    prefix :api

    before do
      error!("401 Unauthorized", 401) unless current_member
    end

    helpers do

      def current_member
        member = member_if_allowed
        authen_token = headers['X-Api-Key']
        error!("401 Unauthorized: No Token", 401) unless authen_token.present?

        member_access_token = member.api_tokens.where('token = ?', authen_token)
        error!("401 Unauthorized: invalid token", 401) unless member_access_token.present?

        @current_member = member
      end

      def member_if_allowed
        member = Member.cached_find(params[:member_id])
        error!("403 Forbidden", 403) if member.blacklist? || member.ban?
        member
      end

    end

    mount Pollios::V1::PollAPI
  end
end