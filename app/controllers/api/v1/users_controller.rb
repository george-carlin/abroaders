module API
  module V1
    class UsersController < APIController

      def index
        render json: User.non_admin
      end

    end
  end
end
