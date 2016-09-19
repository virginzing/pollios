module V1
  class ApplicationFailure < Devise::FailureApp
    def redirect_url
      super
    end

    def respond
      super
    end
  end
end
