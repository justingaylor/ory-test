#!/bin/bash

# set -euxo pipefail

function run-server {
    ruby app.rb
}

function clients-list {
  curl -s "https://$ORY_PROJECT_SLUG.projects.oryapis.com/admin/clients" \
    -H 'Accept: application/json' \
    -H "Authorization: Bearer $ORY_ADMIN_API_KEY"
}

function clients-create {
  curl -s -X POST "https://$ORY_PROJECT_SLUG.projects.oryapis.com/admin/clients" \
    -H 'Content-Type: application/json' \
    -H "Authorization: Bearer $ORY_ADMIN_API_KEY" \
    --data-raw '{
      "metadata": {
        "app": "property",
        "domain": "localhost:3000"
      },
      "allowed_cors_origins": [
        "http://localhost"
      ],
      "token_endpoint_auth_method": "client_secret_post",
      "response_types": [
        "code",
        "token",
        "id_token"
      ],
      "grant_types": [
        "refresh_token",
        "authorization_code"
      ],
      "redirect_uris": [
        "http://localhost:3000/callback"
      ],
      "scope": "openid offline_access",
      "client_name": "Property-Localhost",
      "skip_consent": true
    }'
}

function identities-list {
  curl -s -X GET "https://$ORY_PROJECT_SLUG.projects.oryapis.com/admin/identities" \
    -H 'Accept: application/json' \
    -H "Authorization: Bearer $ORY_ADMIN_API_KEY"
}

function identities-delete {
  curl -s -X DELETE "https://$ORY_PROJECT_SLUG.projects.oryapis.com/admin/identities/$1" \
    -H "Authorization: Bearer $ORY_ADMIN_API_KEY"
}

"$@"