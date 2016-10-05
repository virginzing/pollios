module V1
  class ErrorsController < V1::ApplicationController
    layout 'v1/main'

    before_action :set_meta

    def not_found
    end

    private

    def set_meta
      @meta ||= {
        title: 'Not found',
        description: 'The page you are looking for cannot be found'
      }
    end
  end
end
