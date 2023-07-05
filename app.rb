require 'bundler'
Bundler.require # require all gems in Gemfile

# Load from .env file
Dotenv.load

ORY_ADMIN_API_KEY = ENV['ORY_ADMIN_API_KEY']
ORY_CLIENT_ID     = ENV['ORY_CLIENT_ID']
ORY_CLIENT_SECRET = ENV['ORY_CLIENT_SECRET']
VHOST_DOMAIN      = ENV['VHOST_DOMAIN']
AUTH_HOST         = "https://#{ENV['ORY_PROJECT_SLUG']}.projects.oryapis.com"
REDIRECT_URI      = "http://#{VHOST_DOMAIN}/callback"

set :server, 'webrick'
set :port, 3000
enable :sessions

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => ENV['RACK_SESSION_SECRET'],
                           :expire_after => ENV['RACK_SESSION_EXPIRATION_SECS'].to_i

require_relative 'clients/ory'
require_relative 'managers/invitations'
require_relative 'controllers/login_controller'
require_relative 'controllers/invitations_controller'
require_relative 'controllers/user_invitations_controller'

use LoginController
use InvitationsController
use UserInvitationsController

configure do
  # Ensure we create our invitations SQL table
  Managers::Invitations.instance.setup
end

get '/' do
  if session[:user_id]
    'You are logged in!'
  else
    redirect to('/login')
  end
end