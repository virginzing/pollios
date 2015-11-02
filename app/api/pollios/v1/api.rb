module Pollios::V1
  class API < Grape::API
    mount CurrentMemberAPI::Get
    mount MemberAPI::Get
    mount PollAPI::Get
    mount GroupAPI::Get
  end
end