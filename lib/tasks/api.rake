namespace :api do
  desc 'routes'
  task routes: :environment do
    (Pollios::API.routes | Pollios::Sentai.routes).each do |api|
      method = api.route_method.ljust(8)
      if api.route_version
        path = api.route_path.gsub(':version', api.route_version).ljust(55)
      else
        path = api.route_path.ljust(55)
      end
      description = api.route_description
      puts "     #{method} #{path} #{description}"
    end
  end
end