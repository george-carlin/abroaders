require 'rails_helper'

RSpec.describe 'new recommendation request page' do
  # will raise an error if the account has no monthly spending saved:
  let(:account) { create(:account, :eligible, :onboarded, monthly_spending_usd: 1) }
  let(:owner)   { account.owner }

  before do
    create(:spending_info, person: owner)
    login_as account
  end

  example 'solo account' do
    visit new_recommendation_requests_path(person_type: :owner)
    btn = "My data is all up-to-date - Send me some card recommendations!"
    click_button btn
    owner.reload
    expect(owner.unresolved_recommendation_request?).to be true
  end

  example 'couples account - both people' do
    companion = create(:companion, :eligible, account: account)
    create(:spending_info, person: companion)
    account.reload
    visit new_recommendation_requests_path(person_type: :both)
    btn = "Our data is all up-to-date - Send us some card recommendations!"
    click_button btn
    owner.reload
    expect(owner.unresolved_recommendation_request?).to be true
    expect(companion.unresolved_recommendation_request?).to be true
  end

  # TODO test it's handled gracefully if they already created one in another tab
end
