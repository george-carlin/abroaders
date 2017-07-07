require 'rails_helper'

RSpec.describe RegionsOfInterest::Survey::Save do
  let(:op) { described_class }
  let(:account) { create_account(onboarding_state: 'regions_of_interest') }

  before(:all) { @regions = Array.new(3) { create(:region) } }
  after(:all)  { @regions.each(&:destroy) }
  let(:regions) { @regions }

  let(:selected_regions)    { @regions.first(2) }
  let(:selected_region_ids) { selected_regions.map(&:id) }

  example 'creating ROIs' do
    result = op.(
      { interest_regions_survey: { region_ids: selected_region_ids } },
      'current_account' => account,
    )
    expect(result.success?).to be true

    account.reload
    expect(account.onboarding_state).to eq 'account_type'
    expect(account.regions_of_interest).to match_array(selected_regions)
  end

  example 'with HTTP-like params' do
    string_ids = selected_region_ids.map(&:to_s)
    result = op.(
      { interest_regions_survey: { region_ids: string_ids } },
      'current_account' => account,
    )
    expect(result.success?).to be true

    account.reload
    expect(account.onboarding_state).to eq 'account_type'
    expect(account.regions_of_interest).to match_array(selected_regions)
  end

  # If they don't select any regions, then the params won't have a
  # 'interest_regions_survey' key at all, which I don't think is Rails's fault
  # (it's how HTML handles unchecked checkboxes)
  example 'submitting with no ROIs' do
    result = op.({}, 'current_account' => account)
    expect(result.success?).to be true
    expect(account.regions_of_interest).to be_empty
    expect(account.onboarding_state).to eq 'account_type'
  end

  example 'duplicate IDs' do
    # just ignore the duplicates:
    region = regions.first
    id     = region.id
    expect do
      result = op.(
        { interest_regions_survey: { region_ids: [id, id] } },
        'current_account' => account,
      )
      expect(result.success?).to be true
    end.to change { account.interest_regions.count }.by(1)

    expect(account.regions_of_interest).to match_array [region]
    expect(account.onboarding_state).to eq 'account_type'
  end

  example 'non-existent IDs' do
    raise if selected_region_ids.include?(1234) # sanity check
    expect do
      op.(
        { interest_regions_survey: { region_ids: [1234] } },
        'current_account' => account,
      )
    end.to raise_error(RuntimeError, 'invalid ids')
    expect(account.interest_regions.count).to eq 0
    expect(account.reload.onboarding_state).to eq 'regions_of_interest'
  end
end
