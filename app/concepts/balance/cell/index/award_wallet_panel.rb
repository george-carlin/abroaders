class Balance::Cell::Index < Balance::Cell::Index.superclass
  # Panel at the top of the balances page. If the user has connected their AW
  # account, shows a brief overview of the connection with a link to manage the
  # settings. If they haven't connected, encourage them to connect.
  #
  # @!method self.call(account, opts = {})
  #   @param account [Account] the currently-logged in account.
  class AwardWalletPanel < Abroaders::Cell::Base
    include ::Cell::Builder

    builds do |account|
      account.award_wallet? ? Connected : ConnectPrompt
    end

    private

    def wrapper(&block)
      content_tag :div, class: 'hpanel hblue' do
        content_tag :div, class: 'panel-body text-center', style: 'color: #8492a5;', &block
      end
    end

    # Show them info about the AW account that they already connected.
    class Connected < self
      include Escaped

      property :award_wallet_user

      def show
        wrapper do
          "You're connected to your AwardWallet account <b>#{user_name}</b>. "\
          "#{link_to_settings} #{sync_balances_btn}"
        end
      end

      private

      def link_to_settings
        link_to(
          'Manage settings',
          integrations_award_wallet_settings_path,
          class: 'btn btn-xs btn-primary',
        )
      end

      def user_name
        escape!(award_wallet_user.user_name)
      end

      def sync_balances_btn
        button_tag(
          'Sync Balances',
          class: 'btn btn-xs btn-primary',
          'data-toggle': 'modal',
          'data-target': '#sync_balances_modal',
        )
      end
    end

    # Encourage them to connect to their AwardWallet account.
    class ConnectPrompt < self
      include Integrations::AwardWallet::Links

      def show
        wrapper do
          <<-HTML
            <p class="lead">
              <span class="fa fa-info-circle" style="color: #1fb6ff;"></span>
              Connect your AwardWallet account to Abroaders.
            </p>

            <p class="text-center"><strong>Why?</strong>
              Sharing your points balances with Abroaders allows us to notify
              you when you have enough points to book a flight. It also lets us
              notify you about great deals available with the points and miles
              you have.
            </p>

            #{link_to_connect_with_award_wallet}
          HTML
        end
      end

      private

      def link_to_connect_with_award_wallet
        link_to(
          connect_to_award_wallet_path,
          class: 'btn btn-danger3',
          style: 'background-color: #1fb6ff; color: #ffffff;',
        ) do
          "<i class='fa fa-plug'> </i> Connect to AwardWallet"
        end
      end
    end
  end
end
