require 'rails_helper'

RSpec.describe 'award wallet settings page' do
  include_context 'logged in'

  include AwardWalletMacros

  let!(:aw_user) { setup_award_wallet_user_from_sample_data(account) }
  let(:aw_owners) { aw_user.award_wallet_owners }

  def owner_selector(owner)
    "#award_wallet_owner_#{owner.id}"
  end

  before do
    create_companion(account: account)
    visit integrations_award_wallet_settings_path
  end

  example 'updating owner<>person mapping', :js do
    aw_owner      = aw_owners.first
    person_select = "award_wallet_owner_#{owner.id}_person_id"
    expect(aw_owner.person).to eq account.owner

    select account.companion.first_name, from: person_select
    wait_for_ajax
    expect(aw_owner.reload.person).to eq account.companion

    select 'Someone else', from: person_select
    wait_for_ajax
    expect(aw_owner.reload.person).to be nil

    select account.owner.first_name, from: person_select
    wait_for_ajax
    expect(aw_owner.reload.person).to eq account.owner
  end

  it 'has no recommendation alert' do
    expect(page).to have_no_content 'Your Card Recommendations'
    expect(page).to have_no_content 'Abroaders is Working'
    expect(page).to have_no_content 'Request new card recommendations'
  end
end
