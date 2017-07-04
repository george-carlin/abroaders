require 'rails_helper'

RSpec.describe 'account type select page', :js, :onboarding do
  subject { page }

  let(:account) { create_account(onboarding_state: 'account_type') }
  let(:owner) { account.owner }

  before do
    login_as_account(account)
    visit type_account_path
  end

  let(:solo_btn)    { 'Sign up for solo earning' }
  let(:couples_btn) { 'Sign up for couples earning' }

  def submit_companion_first_name(name)
    fill_in :account_companion_first_name, with: name
    click_button couples_btn
  end

  it { is_expected.to have_title full_title('Select Account Type') }

  it '' do
    expect(page).to have_content '2. Account'
  end

  it 'gives me the option to choose a "Solo" or "Partner" account' do
    expect(page).to have_button solo_btn
    expect(page).to have_button couples_btn
    expect(page).to have_field :account_companion_first_name
  end

  it 'has no sidebar' do
    expect(page).to have_no_sidebar
  end

  example 'choosing "solo"' do
    expect do
      click_button solo_btn
    end.to change { Person.count }.by(0)
    account.reload
    expect(account.onboarding_state).to eq 'eligibility'

    expect(current_path).to eq survey_eligibility_path
  end

  describe 'choosing "couples"' do
    let(:companion_name) { "Steve" }

    example 'without providing a companion name' do
      expect { click_button couples_btn }.not_to change { Person.count }
      # shows an error message and doesn't continue:
      expect(page).to have_error_message
    end

    example 'submitting whitespace as companion name' do
      # strips the whitespace:
      expect do
        submit_companion_first_name('     ')
      end.not_to change { Person.count }
      expect(page).to have_error_message
    end

    example 'providing a companion name' do
      expect do
        submit_companion_first_name(companion_name)
      end.to change { Person.count }.by(1)
      account.reload
      expect(account.companion.first_name).to eq companion_name

      expect(account.onboarding_state).to eq 'eligibility'
      expect(current_path).to eq survey_eligibility_path
    end

    example 'providing a name with trailing whitespace' do
      # strips the whitespace:
      expect do
        submit_companion_first_name('     Steve   ')
      end.to change { Person.count }.by(1)
      account.reload
      expect(account.companion.first_name).to eq 'Steve'
    end

    specify 'companion name can\'t be same as owner name' do
      expect do # case-insensitive, strips whitespace
        submit_companion_first_name("  #{owner.first_name.upcase}  ")
      end.not_to change { Person.count }
      expect(page).to have_error_message
    end
  end
end
