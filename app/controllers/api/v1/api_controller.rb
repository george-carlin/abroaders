module API
  module V1
    class APIController < ApplicationController
      skip_before_action :verify_authenticity_token

      before_action do
        # Allow all requests so that the front-end can call the API via AJAX.
        # TODO: Not sure if this is secure; there's probably a much better way
        # of doing it.
        headers['Access-Control-Allow-Origin'] = '*'
        headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
        headers['Access-Control-Request-Method'] = '*'
        headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
      end

    end
  end
end
