# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Pollios::Application.initialize!
Apn::App::RAILS_ENV = Rails.env

# Rails.cache.silence!