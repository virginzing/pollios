class Authentication::Sentai

  def self.host_url
    production_sentai_url = 'http://codeapp-user.herokuapp.com'
    development_sentai_url = 'http://codeapp-user-dev.herokuapp.com'

    if Rails.env.production?
      return development_sentai_url if ENV[:DEVELOPMENT_SERVER].to_b
      production_sentai_url
    else
      development_sentai_url
    end
  end

  def self.sign_in(params)
    JSON.parse(RestClient.post("#{host_url}/codeapp/signin.json", params).body)
  end

end