require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'rqrcode'
# require 'mongo'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Pollios
  class Application < Rails::Application

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Bangkok'

    config.autoload_paths += %W(#{config.root}/lib #{config.root})

    config.versioncake.default_version = 5
    config.versioncake.supported_version_numbers = (1...6)

    config.generators do |g| 
        g.orm :active_record 
    end

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    I18n.enforce_available_locales = false

    Kaminari.configure do |config|
      config.page_method_name = :per_page_kaminari
    end


  end
end
