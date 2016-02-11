module API
  module V1
    class UsersController < APIController

      def index
        render json: User.includes(:survey).non_admin
      end

    end
  end
end
