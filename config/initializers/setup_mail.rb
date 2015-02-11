ActionMailer::Base.smtp_settings = {  
  :address              => "smtp.gmail.com",  
  :port                 => 587,  
  :domain               => "localhost",  
  :user_name            =>  Figaro.env.gmail_username,  
  :password             =>  Figaro.env.gmail_password,  
  :authentication       => "plain",  
  :enable_starttls_auto => true  
}  

ActionMailer::Base.default_url_options[:host] = Rails.env.production? ? "pollios.com" : "localhost:3000"