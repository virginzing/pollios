module Pollios::V1
  class MemberAPI < Grape::API
    version 'v1', using: :path

    resource :members do

      params do
        requires :id, type: Integer, desc: "member id"
      end

      route_param :id do

        desc "GET /:id return member detail for profile screen of member"
        get do
          { member: Member.find(params[:id]) }
        end

      end # route_param
    end # resource :member

  end # class MemberAPI
end # module