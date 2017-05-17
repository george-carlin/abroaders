module Sessions
  module Cell
    class FacebookConnectButton < Abroaders::Cell::Base
      def show(btn_text)
        link_to '/auth/facebook', class: 'btn btn-facebook btn-block' do
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
