module Requests
  module JsonHelpers
    def json
      @json ||= JSON.parse(response.body)
    end

    def generate_certification
      app = Apn::App.new
      app.apn_dev_cert   = Rails.root.join('config', 'certificates', 'local', 'PolliosDev.pem').read
      app.apn_prod_cert  = Rails.root.join('config', 'certificates', 'server_production', 'PolliosProduction.pem').read
      app.save!
    end

  end

  module JsonApiHelpers
    def json
      @json || JSON.parse(last_response.body)
    end

    def generate_certification
      app = Apn::App.new
      app.apn_dev_cert   = Rails.root.join('config', 'certificates', 'local', 'PolliosDev.pem').read
      app.apn_prod_cert  = Rails.root.join('config', 'certificates', 'server_production', 'PolliosProduction.pem').read
      app.save!
    end

    def set_default_pollios_app
      PolliosApp.create!(name: "Pollios", app_id: "com.pollios.polliosapp", platform: "ios")
      PolliosApp.create!(name: "Pollios Flickz", app_id: "com.pollios.polliosapp.flickz", platform: "ios")
      PolliosApp.create!(name: "Pollios Beta", app_id: "com.pollios.polliosappbeta", platform: "ios")
    end

  end

  module Caching
    def with_caching(on = true)
      caching = ActionController::Base.perform_caching
      ActionController::Base.perform_caching = on
      yield
    ensure
      ActionController::Base.perform_caching = caching
    end

    def without_caching(&block)
      with_caching(false, &block)
    end
  end

end
