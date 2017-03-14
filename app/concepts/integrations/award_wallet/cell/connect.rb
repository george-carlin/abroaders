module Integrations
  module AwardWallet
    module Cell
      class Connect < Trailblazer::Cell
        include FontAwesome::Rails::IconHelper

        private

        AWARD_WALLET_URL = \
          'https://awardwallet.com/m/#/connections/approve/vnawwgqjyt/2'.freeze

        def link_to_award_wallet
          link_to(
            AWARD_WALLET_URL,
            class: 'btn btn-lg btn-info',
            style: 'background-color: #1fb6ff',
          ) do
            "#{fa_icon 'plug'} Connect with AwardWallet"
          end
        end
      end
    end
  end
end
