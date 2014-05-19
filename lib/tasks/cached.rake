namespace :cached do
  desc "Clear Cached"
  task clear: :environment do
    Rails.cache.clear
  end
end