# frozen_string_literal: true
require "rails_helper"

RSpec.describe "the spending info survey", :js, :onboarding do
  subject { page }

  include ActiveJob::TestHelper

  PERSON_FIELDS = %i(
    credit_score has_business_without_ein has_business_with_ein
    has_business_no_business will_apply_for_loan_true
    will_apply_for_loan_false
  ).freeze

  let!(:account)  { create_account(onboarding_state: 'spending') }
  let(:owner)     { account.owner }
  let(:companion) { account.companion }

  before do
    login_as_account(account)
    owner.update!(eligible: owner_eligible)
    account.create_companion!(first_name: 'x', eligible: companion_eligible) if couples
    account.reload
    visit survey_spending_info_path
  end

  let(:couples) { false }
  let(:owner_eligible)     { true }
  let(:companion_eligible) { false }

  let(:submit_form) { click_button "Save and continue" }

  it { is_expected.to have_no_sidebar }
  it { is_expected.to have_title full_title 'Spending Information' }

  context 'solo account, owner eligible' do
    let(:owner_eligible) { true }

    example "submitting a valid form" do
      fill_in :spending_info_owner_credit_score, with: 567
      fill_in :spending_info_monthly_spending, with: 1234
      choose :spending_info_owner_will_apply_for_loan_true
      choose :spending_info_owner_has_business_without_ein
      fill_in :spending_info_owner_business_spending_usd, with: 9876543
      expect { submit_form }.to change { SpendingInfo.count }.by(1)
      account.reload
      expect(account.monthly_spending_usd).to eq 1234
      info = account.owner.spending_info
      expect(info.credit_score).to eq 567
      expect(info.will_apply_for_loan).to be true
      expect(info.has_business).to eq 'without_ein'
      expect(info.business_spending_usd).to eq 9876543
    end
  end

  context 'couples account, only owner eligible' do
    let(:couples) { true }
    let(:companion_eligible) { false }
    let(:owner_eligible)     { true }

    example "submitting a valid form" do
      fill_in :spending_info_owner_credit_score, with: 567
      fill_in :spending_info_monthly_spending, with: 1234
      choose :spending_info_owner_will_apply_for_loan_true
      choose :spending_info_owner_has_business_without_ein
      fill_in :spending_info_owner_business_spending_usd, with: 9876543
      expect { submit_form }.to change { SpendingInfo.count }.by(1)
      account.reload
      expect(account.monthly_spending_usd).to eq 1234
      info = account.owner.spending_info
      expect(info.credit_score).to eq 567
      expect(info.will_apply_for_loan).to be true
      expect(info.has_business).to eq 'without_ein'
      expect(info.business_spending_usd).to eq 9876543
    end
  end

  context 'couples account, only companion eligible' do
    let(:couples) { true }
    let(:companion_eligible) { true }
    let(:owner_eligible)     { false }

    example "submitting a valid form" do
      fill_in :spending_info_companion_credit_score, with: 350
      fill_in :spending_info_monthly_spending, with: 5432
      choose :spending_info_companion_has_business_with_ein
      fill_in :spending_info_companion_business_spending_usd, with: 6857
      expect { submit_form }.to change { SpendingInfo.count }.by(1)
      account.reload
      expect(account.monthly_spending_usd).to eq 5432
      info = account.companion.spending_info
      expect(info.credit_score).to eq 350
      expect(info.will_apply_for_loan).to be false
      expect(info.has_business).to eq 'with_ein'
      expect(info.business_spending_usd).to eq 6857
    end
  end

  context 'couples account, both people eligible' do
    let(:couples) { true }
    let(:companion_eligible) { true }
    let(:owner_eligible)     { true }

    example "repopulating form after invalid submission" do
      fill_in :spending_info_owner_credit_score, with: 900 # too high
      choose :spending_info_owner_has_business_without_ein
      fill_in :spending_info_owner_business_spending_usd, with: 1234
      choose :spending_info_owner_will_apply_for_loan_true
      fill_in :spending_info_companion_credit_score, with: 456
      choose :spending_info_companion_has_business_with_ein
      fill_in :spending_info_companion_business_spending_usd, with: 4321
      choose :spending_info_companion_will_apply_for_loan_true
      fill_in :spending_info_monthly_spending, with: 1312
      expect { submit_form }.not_to change { SpendingInfo.count }
      expect(page).to have_field :spending_info_owner_credit_score, with: 900
      expect(page).to have_field :spending_info_owner_has_business_without_ein, checked: true
      expect(page).to have_field :spending_info_owner_business_spending_usd, with: 1234
      expect(page).to have_field :spending_info_owner_will_apply_for_loan_true, checked: true
      expect(page).to have_field :spending_info_companion_credit_score, with: 456
      expect(page).to have_field :spending_info_companion_has_business_with_ein, checked: true
      expect(page).to have_field :spending_info_companion_business_spending_usd, with: 4321
      expect(page).to have_field :spending_info_companion_will_apply_for_loan_true, checked: true
      expect(page).to have_field :spending_info_monthly_spending, with: 1312
    end

    example "submitting a valid form" do
      fill_in :spending_info_owner_credit_score, with: 350
      fill_in :spending_info_monthly_spending, with: 8761
      fill_in :spending_info_companion_credit_score, with: 648
      choose :spending_info_companion_has_business_with_ein
      fill_in :spending_info_companion_business_spending_usd, with: 6857
      expect { submit_form }.to change { SpendingInfo.count }.by(2)
      account.reload
      expect(account.monthly_spending_usd).to eq 8761
      owner_info = account.owner.spending_info
      expect(owner_info.credit_score).to eq 350
      expect(owner_info.will_apply_for_loan).to be false
      expect(owner_info.has_business).to eq 'no_business'
      comp_info = account.companion.spending_info
      expect(comp_info.credit_score).to eq 648
      expect(comp_info.will_apply_for_loan).to be false
      expect(comp_info.has_business).to eq 'with_ein'
      expect(comp_info.business_spending_usd).to eq 6857
    end
  end

  example "hiding and showing the business spending input" do
    choose :spending_info_owner_has_business_with_ein
    expect(page).to have_field :spending_info_owner_business_spending_usd
    choose :spending_info_owner_has_business_no_business
    expect(page).to have_no_field :spending_info_owner_business_spending_usd
    choose :spending_info_owner_has_business_without_ein
    expect(page).to have_field :spending_info_owner_business_spending_usd
    choose :spending_info_owner_has_business_no_business
    expect(page).to have_no_field :spending_info_owner_business_spending_usd
  end
end
