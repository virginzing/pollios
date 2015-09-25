namespace :grape do
  desc "routes"
  task :routes => :environment do
    Pollios::API.routes.map { |route| puts "#{route} \n" }
  end
end