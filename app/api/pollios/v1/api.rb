module Pollios::V1
  class API < Grape::API
    mount CurrentMemberAPI::Get
    mount CurrentMemberAPI::Post
    mount CurrentMemberAPI::Put
    mount CurrentMemberAPI::Delete
    mount MemberAPI::Get
    mount MemberAPI::Post
    mount PollAPI::Get
    mount PollAPI::Post
    mount PollAPI::Delete
    mount GroupAPI::Get
    mount GroupAPI::Post
    mount GroupAPI::Put
    mount SearchAPI::Get
    mount SearchAPI::Post
  end
end