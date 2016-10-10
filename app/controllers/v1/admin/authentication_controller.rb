module V1::Admin
  class AuthenticationController < Devise::SessionsController
    layout 'v1/admin/auth'

    before_action :set_meta

    private

    def after_sign_in_path_for(resource)
      '/admin/dashboard'
    end

    def set_meta
      @meta ||= {
        title: 'Administration',
        description: 'Pollios Administration'
      }
    end
  end
end
