class ApplicationController < Sinatra::Base
  set :views, Proc.new { File.join(settings.root, "../views") }

  def ory_client
    @client ||= Clients::Ory.new(
      auth_host: AUTH_HOST, 
      api_key: ORY_ADMIN_API_KEY
    )
  end

  def self.fail(msg="Something went wrong")
    halt 500, msg
  end
end