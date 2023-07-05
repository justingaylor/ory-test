module Clients
  class Ory
    attr_accessor :auth_host, :api_key

    def initialize(auth_host:, api_key:)
      self.auth_host = auth_host
      self.api_key = api_key
    end

    def get_token_from_auth_code(auth_code:, redirect_uri:, client_id:, client_secret:)
      token_url = "#{auth_host}/oauth2/token"
      HTTParty.post(
        token_url, 
        body: {
          grant_type: 'authorization_code',
          code: auth_code,
          redirect_uri: redirect_uri,
          client_id: client_id,
          client_secret: client_secret,
          scope: 'openid'
        }
      )
    end

    def get_jwks
      jwks_uri = "#{auth_host}/.well-known/jwks.json"
      HTTParty.get(jwks_uri)
    end

    def get_client(client_id)
      uri = "#{auth_host}/admin/clients/#{client_id}"
      HTTParty.get(uri, headers: admin_api_headers(api_key))
    end

    def get_userinfo(access_token)
      uri = "#{auth_host}/userinfo"
      HTTParty.get(uri, headers: admin_api_headers(access_token))
    end

    def create_user(email)
      uri = "#{auth_host}/admin/identities"
      headers = admin_api_headers(api_key).merge('Content-Type': 'application/json')
      payload = {
        schema_id: 'preset://username',
        traits: {
          username: email
        }
      }
      HTTParty.post(uri, body: payload.to_json, headers: headers)
    end

    def get_user_recovery_link(user_id)
      uri = "#{auth_host}/admin/recovery/link"
      headers = admin_api_headers(api_key).merge('Content-Type': 'application/json')
      payload = {
        expires_in: '8h',
        identity_id: user_id
      }
      HTTParty.post(uri, body: payload.to_json, headers: headers)
    end

    protected

    def admin_api_headers(bearer_token)
      { 
        "Authorization" => "Bearer #{bearer_token}"
      }
    end
  end
end