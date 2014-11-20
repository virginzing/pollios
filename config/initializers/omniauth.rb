OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, Figaro.env.facebook_app_id, Figaro.env.facebook_secret, scope: "email, publish_stream, manage_pages, photo_upload, publish_actions, user_photos, friends_photos"
end

