module Integrations
  module AwardWallet
    module Links
      def edit_account_on_award_wallet_path(aw_account)
        "https://awardwallet.com/account/edit/#{aw_account.award_wallet_id}"
      end

      def admin_award_wallet_account_list_url(aw_user)
        "https://business.awardwallet.com/account/list#/?agentId=#{aw_user.agent_id}"
      end
    end
  end
end
