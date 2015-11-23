namespace :api do
  desc 'routes'
  task routes: :environment do
    Pollios::API.routes.each do |api|
      method = api.route_method.ljust(8)
      path = api.route_path.gsub(':version', api.route_version).ljust(55)
      description = api.route_description
      puts "     #{method} #{path} #{description}"
    end
  end
end