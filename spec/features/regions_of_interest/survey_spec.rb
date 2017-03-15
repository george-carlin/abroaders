require 'rails_helper'

RSpec.describe 'regions of interest survey' do
  def check_checkbox(name)
    find(:checkbox, name).trigger('click')
  end

  let(:account) { create(:account, onboarding_state: :regions_of_interest) }
  let(:regions) { Region.all }

  before do
    login_as_account(account)
    visit survey_interest_regions_path
  end

  let(:submit_form) { click_on 'Save and continue' }

  example 'initial page layout' do
    expect(page).to have_no_sidebar
    expect(page).to have_button 'Save and continue'
    expect(page).to have_content 'Interested in any of these locations?'
    regions.each do |region|
      expect(page).to have_content region.name
      expect(page).to have_field "interest_regions_survey_region_codes_#{region.code}"
    end
  end

  example 'selecting some regions' do
    check regions[0].name
    check regions[2].name
    expect do
      submit_form
      account.reload
    end.to change { account.regions_of_interest.count }.by(2)
    expect(account.regions_of_interest).to match_array [regions[0], regions[2]]
    expect(current_path).to eq type_account_path
  end

  example 'selecting none' do
    expect { submit_form }.not_to change { InterestRegion.count }
    expect(current_path).to eq type_account_path
  end
end
