# Superclass for all controllers whose actions are intended to be used by
# logged-in 'normal', non-admin accounts.
class AuthenticatedUserController < ApplicationController
  before_action :authenticate_account!
  before_action :redirect_if_not_onboarded!

  private

  # TODO is this the correct Trailblazer-y way to do this?
  def params!(params)
    params.to_unsafe_h.merge(current_account: current_account)
  end
end
