namespace :certificate do
  desc "Setup certificate"
  task setup: :environment do
     app = Apn::App.new
     app.apn_dev_cert   = Rails.root.join('config', 'certificates', 'local', 'PolliosDev.pem').read
     app.apn_prod_cert  = Rails.root.join('config', 'certificates', 'server_production', 'PolliosProduction.pem').read
     app.save!
     puts "Setup Success."
  end

  desc "Clear certificates"

  task clear: :environment do
    Apn::App.all.delete_all
    puts "Clear certificates successfully."
  end

  desc "Update certificates"
  task :update => :environment do
    app = Apn::App.first
    app.apn_dev_cert   = Rails.root.join('config', 'certificates', 'local', 'PolliosDev.pem').read
    app.apn_prod_cert  = Rails.root.join('config', 'certificates', 'server_production', 'PolliosProduction.pem').read
    app.save!
  end

end
