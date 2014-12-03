module Requests
  module JsonHelpers
    def json
      @json ||= JSON.parse(response.body)
    end
  end

  module JsonApiHelpers
    def json
      @json || JSON.parse(last_response.body)
    end
  end
end