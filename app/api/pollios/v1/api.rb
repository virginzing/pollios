module Pollios::V1
  class API < Grape::API
    mount InAppAPI::Get
    mount InAppAPI::Post
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
    mount GroupAPI::Delete
    mount SearchAPI::Get
    mount SearchAPI::Post
    mount CampaignAPI::Post
  end
end