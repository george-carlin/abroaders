require 'rails_helper'

RSpec.describe Integrations::AwardWalletController do
  include AwardWalletMacros
  include SampleDataMacros

  let(:account) { create(:account, :onboarded) }
  before { sign_in account }

  describe 'GET #settings' do
    subject { get :settings }

    context 'when account is not connected to AW' do
      it { is_expected.to redirect_to balances_path }
    end

    context 'when account is connected to AW' do
      # create the unloaded AwardWalletUser:
      let!(:awu) { get_award_wallet_user_from_callback(account) }

      context 'but AW data is not loaded' do
        it { is_expected.to redirect_to balances_path }
      end

      context 'and AW data is loaded' do
        before do
          stub_award_wallet_api(sample_json('award_wallet_user'))
          r = Integrations::AwardWallet::User::Operation::Refresh.(user: awu)
          raise unless r.success? # sanity check
        end

        it { is_expected.to have_http_status(200) }
      end
    end
  end
end
