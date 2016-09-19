module V1::Admin
  class AuthenticationController < Devise::SessionsController 
    layout 'v1/navbar_no_sidebar'
    
    private

    def after_sign_in_path_for(resource)
      '/v1/admin/dashboard'
    end
  end
end
