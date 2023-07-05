require_relative 'application_controller'

class InvitationsController < ApplicationController
  # Invitations#index
  get '/invitations' do
    invitations = invitations_manager.get_invitations
    invitations.to_json
  end

  # Invitations#create
  get '/users/:user_id/invitations' do
    # Create a new invitation for specified user
    user_id = params[:user_id]
    invitation_id = invitations_manager.create_invitation_for_user user_id
    invitation_uri = "http://#{VHOST_DOMAIN}/invitations/#{invitation_id}/complete"

    "You have been invited to Acme Properties!<br />" +
    "<a href=\"#{invitation_uri}\">Accept invitation</a>"
  end

  # Invitations#complete
  get '/invitations/:invitation_id/complete' do
    invitation_id = params[:invitation_id]
    invitation = invitations_manager.get_invitation invitation_id
    fail 'Invitation not found' unless invitation
    fail 'Invitation is not pending' unless invitation[:status] == 'pending'
    #############################################
    # TODO: Finish registration of invited user
    #############################################
    invitations_manager.complete_invitation invitation_id
    'Invitation complete! Welcome to Acme Properties!!'
  end

  def invitations_manager
    InvitationsManager.instance
  end
end
  