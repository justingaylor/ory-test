require_relative 'application_controller'

class LoginController < ApplicationController
  get '/login' do
    auth_server_url = "#{AUTH_HOST}/oauth2/auth" # Replace with your OAuth2 server's URL
    state = { "original_url" => "/" }
    encoded_state = Base64.encode64(state.to_json)
  
    redirect_url = "#{auth_server_url}?state=#{encoded_state}&response_type=code&client_id=#{ORY_CLIENT_ID}&redirect_uri=#{REDIRECT_URI}"
    redirect to(redirect_url)
  end
  
  get '/callback' do
    # Exchange the authorization code for an access token
    auth_code = params[:code]
    token_response = ory_client.get_token_from_auth_code(
      auth_code: auth_code,
      redirect_uri: REDIRECT_URI,
      client_id: ORY_CLIENT_ID,
      client_secret: ORY_CLIENT_SECRET
    )
    fail 'Failed to retrieve access token' unless token_response.code == 200
    
    access_token = JSON.parse(token_response.body)['access_token']
  
    # Decode JWT header to get the KID
    header_segment = access_token.split('.').first
    decoded_header = JSON.parse(Base64.urlsafe_decode64(header_segment))
    kid = decoded_header['kid']
  
    # Fetch the public keys from authorization server
    response = ory_client.get_jwks
    fail 'Failed to fetch JSON Web Key Set' unless response.code == 200
    
    jwks_raw = JSON.parse(response.body)
    jwks_keys = jwks_raw['keys']
  
    # Find the key with the matching KID
    matching_key_data = jwks_keys.find { |key| key['kid'] == kid }
    fail 'No matching key found in JSON Web Key Set' unless matching_key_data
    
    jwk = JWK::Key.from_json(matching_key_data.to_json)
    
    # Decode and verify the JWT
    decoded_token = JWT.decode(access_token, jwk.to_openssl_key, true, algorithm: jwk.alg) # Replace 'RS256' with your algorithm if different
    decoded_token_body = decoded_token[0]
    
    # Check issuer
    iss = decoded_token_body['iss']
    fail "Invalid token issuer: #{iss}" unless iss == AUTH_HOST
  
    # Check client
    client_id = decoded_token_body['client_id']
    response = ory_client.get_client(client_id)
    fail "Failed to fetch client for id: #{client_id}" unless response.code == 200
    metadata = response['metadata']
    fail 'Metadata is missing from client' unless metadata
    fail 'JWT is not for this app!' unless metadata['app'] == 'property'
    fail 'JWT is not for this vhost!' unless metadata['domain'] == VHOST_DOMAIN
  
    # Query the user's info from Ory
    response = ory_client.get_userinfo(access_token)
    fail 'Unable to fetch userinfo' unless response.code == 200
    user_info = JSON.parse(response.body)
    
    # Setup our session and redirect to
    session[:user_id] = user_info['sub']
    redirect to('/')
  end
end