module API
  module V1
    class AccountsController < APIController

      def index
        render json: Account.includes(:survey).non_admin
      end

    end
  end
end
