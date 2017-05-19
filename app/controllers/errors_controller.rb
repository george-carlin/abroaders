class ErrorsController < ApplicationController
  def not_found
    render cell(Errors::Cell::NotFound)
  end

  def internal_server_error
    render cell(Errors::Cell::InternalServerError)
  end
end
