require 'bootstrap_overrides'

module Sessions
  module Cell
    # @!method self.call(user)
    #   @param user [Admin|Account]
    class New < Abroaders::Cell::Base
      include ::Cell::Builder

      builds do |user|
        case user
        when Account then SignInAccount
        when Admin   then SignInAdmin
        else raise "unrecognised user #{user.inspect}"
        end
      end

      def show
        render view: 'new' # use the same ERB file even in subclasses
      end

      private

      def form_tag(&block)
        form_for(
          model,
          as: resource_name,
          url: new_session_path,
          html: { role: "form" },
          &block
        )
      end

      def link_to_recover_password
        link_to 'Forgot your password?', new_password_path
      end

      def link_to_sign_in_with_facebook
        cell(Sessions::Cell::FacebookConnectButton).sign_in
      end

      class SignInAccount < self
        def title
          'Sign In'
        end

        private

        def link_to_register
          link_to(
            'Register',
            new_account_registration_path,
            class: 'btn btn-default btn-block',
          )
        end

        def new_password_path
          new_account_password_path
        end

        def new_session_path
          new_account_session_path
        end

        def resource_name
          :account
        end
      end

      class SignInAdmin < self
        def title
          'Admin Sign In'
        end

        private

        def link_to_register
          '' # admins can't register
        end

        def link_to_sign_in_with_facebook
          ''
        end

        def new_password_path
          new_admin_password_path
        end

        def new_registration_path
          new_admin_registration_path
        end

        def new_session_path
          new_admin_session_path
        end

        def resource_name
          :admin
        end
      end
    end
  end
end
