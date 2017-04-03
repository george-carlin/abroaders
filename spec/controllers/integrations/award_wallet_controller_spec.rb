require 'rails_helper'

RSpec.describe Integrations::AwardWalletController do
  include AwardWalletMacros

  let(:account) { create(:account, :onboarded) }

  before { sign_in account }

  describe 'GET #callback' do
    subject { get :callback, params: { userId: '1' } }

    context 'when I already have a loaded AwardWalletUser' do
      before { setup_award_wallet_user_from_sample_data(account) }
      it { is_expected.to redirect_to integrations_award_wallet_settings_path }
    end

    context 'when I already have an unloaded AwardWalletUser' do
      before { get_award_wallet_user_from_callback(account) }
      it { is_expected.to have_http_status(200) }
    end

    context "when I don't already have an AwardWalletUser" do
      it { is_expected.to have_http_status(200) }

      example "and there's no userId in the params" do
        expect do
          get :callback, params: { userId: '' }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    example 'when the user denied the permissions' do
      expect(
        get(:callback, params: { denyAccess: '1' }),
      ).to redirect_to balances_path
    end
  end

  describe 'GET #settings' do
    subject { get :settings }

    context 'when I have a loaded AwardWalletUser' do
      before { setup_award_wallet_user_from_sample_data(account) }
      it { is_expected.to have_http_status(200) }
    end

    context 'when I have an unloaded AwardWalletUser' do
      before { get_award_wallet_user_from_callback(account) }
      it { is_expected.to redirect_to balances_path }
    end

    context 'when I have no AwardWalletUser' do
      it { is_expected.to redirect_to balances_path }
    end
  end
end
