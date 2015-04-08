require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'rqrcode'
require 'htmlentities'
require 'yajl'
require 'itunes/receipt'
require 'net/http'
require 'roo'
require 'csv'
require 'spreadsheet'
require 'zip'
require 'rqrcode_png'


# MultiJson.engine = :yajl
# Benchmark.bmbm(5) do |x|
#   x.report 'activesupport' do
#     1000.times {ActiveSupport::JSON.encode(sample)}
#   end
#   x.report 'yajl' do
#     1000.times {MultiJson.encode(sample)}
#   end
# end

# require 'mongo'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

ENV['RAILS_ADMIN_THEME'] = 'flatly_theme'


module Pollios
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Bangkok'
    
    config.autoload_paths += %W(#{config.root}/lib #{config.root})

    config.assets.precompile += %w(.svg .eot .woff .ttf .js .css)

    config.versioncake.default_version = 6
    config.versioncake.supported_version_numbers = (1...8)

    config.generators do |g| 
      g.orm :active_record
    end

    # config.serve_static_assets = true

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    I18n.enforce_available_locales = false

    Kaminari.configure do |config|
      config.page_method_name = :per_page_kaminari
    end

    # config.active_record.schema_format = :sql

    # config.action_dispatch.rescue_responses["MobilesController::Forbidden"] = :forbidden
    config.exceptions_app = self.routes
    # Compass.sass_engine_options[:load_paths].collect { |path| path.try(:root) }.compact

    config.action_controller.page_cache_directory = "#{Rails.root.to_s}/public/deploy"
    
    config.middleware.use BatchApi::RackMiddleware do |batch_config|
      # you can set various configuration options:
      # batch_config.verb = :post # default :post
      batch_config.endpoint = "/batchapi" # default /batch
      batch_config.limit = 100 # how many operations max per request, default 50

      # default middleware stack run for each batch request
      batch_config.batch_middleware = Proc.new { }
      # default middleware stack run for each individual operation
      batch_config.operation_middleware = Proc.new { }
    end

  end
end

