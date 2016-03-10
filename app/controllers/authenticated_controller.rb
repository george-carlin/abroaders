# Superclass for all controllers which are only accessible by logged in users
class AuthenticatedController < ApplicationController

  before_action :authenticate_account!

end
