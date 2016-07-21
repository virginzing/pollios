module Authenticable

  def authenticate_with_token!
    redirect_to_download_link

    # closed old API

    # member = valid_current_member
    # unless Rails.env.test? || Rails.env.development?
    #   token_from_header = request.headers['Authorization']
    #   raise ExceptionHandler::Unauthorized, "Access Denied." unless token_from_header.present?
    #   authenticate_or_request_with_http_token do |token, _options|
    #     access_token = member.api_tokens.where('token = ?', token)
    #     raise ExceptionHandler::Unauthorized, ExceptionHandler::Message::Token::INVALID unless access_token.present?
    #     true
    #   end
    # end
  end

  def valid_current_member
    @current_member = Member.cached_find(params[:member_id])
    raise ExceptionHandler::Forbidden, ExceptionHandler::Message::Member::BLACKLIST if @current_member.blacklist?
    raise ExceptionHandler::Forbidden, ExceptionHandler::Message::Member::BAN if @current_member.ban?
    Member.current_member = @current_member
    @current_member
  end

  private

  def redirect_to_download_link
    download_link = 'https://itunes.apple.com/us/app/pollios/id901397748?ls=1&mt=8'


    redirect_to download_link
  end

end
