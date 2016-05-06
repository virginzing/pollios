namespace :rpush do
  
  desc 'new rpush app in development'
  task development: :environment do
    app = Rpush::Apns::App.new
    app.name = 'Pollios'
    app.environment = 'development'
    app.certificate = Rails.root.join('config', 'certificates', 'server_production', 'new_pollios_production_cer.pem').read
    app.save!
  end

  desc 'new rpush app in production'
  task production: :environment do
    app = Rpush::Apns::App.new
    app.name = 'Pollios'
    app.environment = 'production'
    app.certificate = Rails.root.join('config', 'certificates', 'server_production', 'new_pollios_production_cer.pem').read
    app.save!
  end

end