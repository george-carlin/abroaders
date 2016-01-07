module API
  module V1
    class UsersController < APIController

      def index
        render json: User.all
      end

    end
  end
end
