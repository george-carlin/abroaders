module Integrations
  module AwardWallet
    module Links
      def admin_award_wallet_account_list_url(aw_user)
        "https://business.awardwallet.com/account/list#/?agentId=#{aw_user.agent_id}"
      end

      def edit_account_on_award_wallet_path(aw_account)
        "https://awardwallet.com/account/edit/#{aw_account.award_wallet_id}"
      end

      def connect_to_award_wallet_path
        'https://awardwallet.com/m/#/connections/approve/vnawwgqjyt/2'
      end
    end
  end
end
