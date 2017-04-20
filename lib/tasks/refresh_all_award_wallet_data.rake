namespace :ab do
  task refresh_all_award_wallet_data: :environment do
    Integrations::AwardWallet::User::Refresh::All.()
  end
end
