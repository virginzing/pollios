module Pollios
  class APIEntity < Grape::Entity
    expose :method
    expose :path
    expose :description, if: -> (obj, _) { obj.route_description.present? }
    expose :params

    def method
      object.route_method
    end

    def path
      object.route_path.gsub(':version', version)
    end

    def description
      object.route_description
    end

    def params
      object.route_params
    end

    def version
      return object.route_version if object.route_version
      ''
    end
  end
end