require_relative 'application_controller'

class UserInvitationsController < ApplicationController
    # Invite a user
    get '/invite_user' do  
      erb :invite_user
    end

    post '/create_invitation' do
      fail 'Required POST data "email" is missing' unless params['email']
      # INSTRUCTIONS: https://www.ory.sh/docs/kratos/manage-identities/invite-users
      #
      # NOTE: Had to follow below instructions before this would work. 
      # Enabling via console didn't work:
      # https://www.ory.sh/docs/kratos/self-service/flows/account-recovery-password-reset#configuration
      #
      # STEP 1: Create a new user account
      response = ory_client.create_user(params['email'])
      fail "Failed to create user: #{JSON.parse(response.body)['error']['message']}" unless response.code == 201
      
      # Step 2: Get the ID of the created account from the API response
      user_id = response['id']
      
      # Step 3: Use the account ID to get the recovery link for that account
      response = ory_client.get_user_recovery_link(user_id)
      fail 'Failed to get recovery link' unless response.code == 200 && response['recovery_link']

      # Step 4: Copy the recovery link from the API response and send it to the user
      recovery_link = response['recovery_link']
      erb :create_invitation, locals: { recovery_link: recovery_link }
    end
  end
    