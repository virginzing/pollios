module Pollios::V1
  class API < Grape::API
    mount CurrentMemberAPI::Get
    mount MemberAPI::Get
    mount MemberAPI::Post
    mount PollAPI::Get
    mount PollAPI::Post
    mount PollAPI::Delete
    mount GroupAPI::Get
    mount GroupAPI::Post
    mount SearchAPI::Get
    mount SearchAPI::Post
  end
end