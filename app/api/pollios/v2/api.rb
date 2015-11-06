module Pollios::V2
  class API < Grape::API
    mount CurrentMemberAPI::Get
  end
end