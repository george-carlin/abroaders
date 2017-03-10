require 'rails_helper'

RSpec.describe Integrations::AwardWalletController do
  let(:account) { create(:account, :onboarded) }

  before { sign_in account }

  # TODO there should be a test for the redirects on ':connect' but it seems
  # to have been lost; look in the git history and on other branches
  skip 'GET connect' do
    subject { get :connect }

    context "when I already have an unloaded AwardWalletUser" do
      # TODO replace with op
      before { account.create_award_wallet_user!(aw_id: 1) }
      it { is_expected.to redirect_to integrations_award_wallet_callback_path }
    end

    context "when I already have a loaded AwardWalletUser" do
      # TODO replace with op
      before { account.create_award_wallet_user!(aw_id: 1, loaded: true) }
      it { is_expected.to redirect_to balances_path }
    end

    context "when I don't already have an AwardWalletUser" do
      it { is_expected.to have_http_status(200) }
    end
  end
end
