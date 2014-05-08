namespace :certificate do
  desc "Setup certificate"
  task setup: :environment do
     app = APN::App.new   
     app.apn_dev_cert   = Rails.root.join('config', 'certificates','ApPinkCertificateDevelopment.pem').read
     app.apn_prod_cert  = Rails.root.join('config', 'certificates','ApPinkCertificateProduction.pem').read
     app.save!
     puts "Setup Success."
  end

  desc "Clear certificates"

  task clear: :environment do
    APN::App.all.delete_all
    puts "Clear certificates successfully."  
  end

  desc "Update certificates"
  task :update => :environment do
    app = APN::App.first
    app.apn_dev_cert   = Rails.root.join('config', 'certificates','apple_push_notification_pollios_dev.pem').read
    app.apn_prod_cert  = Rails.root.join('config', 'certificates','apple_push_notification_pollios_pro.pem').read
    app.save!
  end

end
