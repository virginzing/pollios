# APNS.host = "gateway.sandbox.push.apple.com"
# APNS.pem = File.join(Rails.root, 'config', 'certificates', 'pollios_notification_development.pem')

# # Set the environment variable `APPLE_SANDBOX` to use the development certificate in production
# if Rails.env.production?
#   APNS.host = "gateway.push.apple.com"
#   APNS.pem = File.join(Rails.root, 'config', 'certificates', 'pollios_notification_production.pem')
# end