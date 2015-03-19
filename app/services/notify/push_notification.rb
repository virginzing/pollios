class Notify::PushNotification

  def initialize(params = {})
    @params = params
  end

  def env
    if @params[:env] == "production"
      APNS.host = "gateway.push.apple.com"
      APNS.pem = File.join(Rails.root, 'config', 'certificates', 'pollios_notification_production.pem')
    else
      APNS.host = "gateway.sandbox.push.apple.com"
      APNS.pem = File.join(Rails.root, 'config', 'certificates', 'pollios_notification_development.pem')
    end
  end
  
  def device_token
    @params[:device_token]  
  end

  def alert
    @params[:alert].presence || 'Pollios'
  end

  def badge
    @params[:badge].to_i == 0 ? 1 : @params[:badge].to_i
  end

  def sound
    @params[:sound].presence || 'default'
  end

  def new_notification
    APNS::Notification.new(device_token, alert: alert, badge: badge, sound: sound, content_available: 1)
  end

  def send
    env
    n = new_notification
    APNS.send_notifications([n])
    true
  end



end

# APNS.host = "gateway.push.apple.com"
# APNS.pem = File.join(Rails.root, 'config', 'certificates', 'pollios_notification_production.pem')
# n = APNS::Notification.new("611a6722 ef1dbc1b 97e7e48e b91f14c5 2c1c6cdc 79241b1a f1101a17 dca4f81d", badge: 15, sound: true)
# APNS.send_notifications([n])
# true
