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

    def generate_certification
      app = Apn::App.new   
      app.apn_dev_cert   = Rails.root.join('config', 'certificates','pollios_notification_development.pem').read
      app.apn_prod_cert  = Rails.root.join('config', 'certificates','pollios_notification_production.pem').read
      app.save!
    end

  end
end