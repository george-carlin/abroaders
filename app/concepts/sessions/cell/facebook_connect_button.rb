module Sessions
  module Cell
    class FacebookConnectButton < Abroaders::Cell::Base
      def show(btn_text)
        # Don't use a class name that includes 'facebook' or 'fb' or we risk
        # the button being hidden by some users' ad blockers.
        link_to '/auth/facebook', class: 'btn btn-connect btn-block' do
          "<i class='fa fa-facebook-square'> </i> #{btn_text}"
        end
      end

      def sign_in
        show('Log in with Facebook')
      end

      def sign_up
        show('Sign up with Facebook')
      end
    end
  end
end
