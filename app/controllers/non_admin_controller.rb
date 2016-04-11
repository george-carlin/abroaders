# Superclass for all controllers whose actions are intended to be used by
# logged-in 'normal', non-admin accounts.
class NonAdminController < ApplicationController
  before_action :authenticate_account!

end
