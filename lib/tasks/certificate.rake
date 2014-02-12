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

end
