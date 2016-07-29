module Authenticable

  def authenticate_with_token!
    # redirect_to_not_support_link

    # closed old API
    member = valid_current_member
    unless Rails.env.test? || Rails.env.development?
      token_from_header = request.headers['Authorization']
      raise ExceptionHandler::Unauthorized, "Access Denied." unless token_from_header.present?
      authenticate_or_request_with_http_token do |token, _options|
        access_token = member.api_tokens.where('token = ?', token)
        raise ExceptionHandler::Unauthorized, ExceptionHandler::Message::Token::INVALID unless access_token.present?
        true
      end
    end
  end

  def valid_current_member
    @current_member = Member.cached_find(params[:member_id])
    raise ExceptionHandler::Forbidden, ExceptionHandler::Message::Member::BLACKLIST if @current_member.blacklist?
    raise ExceptionHandler::Forbidden, ExceptionHandler::Message::Member::BAN if @current_member.ban?
    Member.current_member = @current_member
    @current_member
  end

  private

  # def redirect_to_not_support_link
  #   not_support_link = 'http://pollios.com/v1/polls/OTcxOTI3'

  #   redirect_to not_support_link
  # end

end
