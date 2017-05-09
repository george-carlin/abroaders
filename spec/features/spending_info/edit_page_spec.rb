require 'rails_helper'

RSpec.describe 'the spending info edit page' do
  subject { page }

  include ActiveJob::TestHelper

  let!(:account) { create(:account, :onboarded) }
  let(:person)   { account.owner }

  before do
    login_as(account, scope: :account)
    account.create_companion!(first_name: 'Gabi') if couples?
    create(:spending_info, person: person)
    visit edit_person_spending_info_path(person)
  end

  let(:couples?) { false }
  let(:submit_form) { click_button 'Save' }

  example 'page layout' do
    expect(page).to have_sidebar
    expect(page).to have_field :spending_info_credit_score
    expect(page).to have_field :spending_info_will_apply_for_loan_true
    expect(page).to have_field :spending_info_will_apply_for_loan_false
    expect(page).to have_field :spending_info_has_business_with_ein
    expect(page).to have_field :spending_info_has_business_without_ein
    expect(page).to have_field :spending_info_has_business_no_business, checked: true
    expect(page).to have_no_field :spending_info_ready_true
    expect(page).to have_no_field :spending_info_ready_false
    # Not initially visible:
    expect(page).to have_no_field :spending_info_business_spending_usd
  end

  example 'hiding and showing the business spending input', :js do
    choose :spending_info_has_business_with_ein
    expect(page).to have_field :spending_info_business_spending_usd
    choose :spending_info_has_business_no_business
    expect(page).to have_no_field :spending_info_business_spending_usd
    choose :spending_info_has_business_without_ein
    expect(page).to have_field :spending_info_business_spending_usd
    choose :spending_info_has_business_no_business
    expect(page).to have_no_field :spending_info_business_spending_usd
  end

  specify "don't save business spending when person has no business", :js do
    fill_in :spending_info_monthly_spending_usd, with: 50
    fill_in :spending_info_credit_score, with: 456
    choose :spending_info_has_business_with_ein
    fill_in :spending_info_business_spending_usd, with: 1234
    choose :spending_info_has_business_no_business
    expect { submit_form }.not_to change { SpendingInfo.count }

    person.reload
    spending_info = person.spending_info
    expect(spending_info.business_spending_usd).to be_blank
  end

  specify "submitting invalid form doesn't forget business info", :js do # bug fix
    choose :spending_info_has_business_with_ein
    expect { submit_form }.not_to change { SpendingInfo.count }
    expect(page).to have_field :spending_info_has_business_with_ein, checked: true
    expect(page).to have_field :spending_info_business_spending_usd
  end

  example 'submitting valid info with no business' do
    fill_in :spending_info_monthly_spending_usd, with: 50
    fill_in :spending_info_credit_score, with: 456
    choose  :spending_info_will_apply_for_loan_true
    expect { submit_form }.not_to change { SpendingInfo.count }

    person.reload
    spending_info = person.spending_info
    expect(spending_info.credit_score).to eq 456
    expect(spending_info.will_apply_for_loan).to be_truthy
    expect(spending_info.has_business).to eq 'no_business'
  end

  example 'submitting valid info with business', :js do
    fill_in :spending_info_monthly_spending_usd, with: 50
    fill_in :spending_info_credit_score, with: 456
    choose  :spending_info_will_apply_for_loan_true
    choose  :spending_info_has_business_without_ein
    fill_in :spending_info_business_spending_usd, with: 5000
    expect { submit_form }.not_to change { SpendingInfo.count }

    person.reload
    spending_info = person.spending_info
    expect(spending_info.credit_score).to eq 456
    expect(spending_info.will_apply_for_loan).to be_truthy
    expect(spending_info.has_business).to eq 'without_ein'
    expect(spending_info.business_spending_usd).to eq 5000
  end

  specify "after submitting the form I'm taken to the card survey page" do
    fill_in :spending_info_monthly_spending_usd, with: 50
    fill_in :spending_info_credit_score, with: 456
    submit_form
    expect(current_path).to eq root_path
  end

  example 'submitting invalid information' do
    fill_in :spending_info_monthly_spending_usd, with: nil
    fill_in :spending_info_credit_score, with: nil
    expect { submit_form }.not_to change { SpendingInfo.count }
    expect(page).to have_selector 'form.edit_spending_info'
    expect(page).to have_error_message
    within '.alert.alert-danger' do
      expect(page).to have_content "Monthly spending usd can't be blank"
      expect(page).to have_content "Credit score can't be blank"
    end
  end

  specify "don't lose previous 'will apply for loan' selection" do
    # Bug fix
    expect(page).to have_field :spending_info_will_apply_for_loan_false, checked: true
    submit_form
    expect(page).to have_field :spending_info_will_apply_for_loan_false, checked: true
    submit_form
    choose :spending_info_will_apply_for_loan_true
    submit_form
    expect(page).to have_field :spending_info_will_apply_for_loan_true, checked: true
  end

  example 'show human-friendly error message for invalid business spending', :js do # bug fix
    choose :spending_info_has_business_with_ein
    submit_form
    within '.alert.alert-danger' do
      expect(page).to have_content "Business spending can't be blank"
    end
  end

  example 'page layout' do
    expect(page).to have_sidebar
    expect(page).to have_field :spending_info_credit_score
    expect(page).to have_field :spending_info_will_apply_for_loan_true
    expect(page).to have_field :spending_info_will_apply_for_loan_false
    expect(page).to have_field :spending_info_has_business_with_ein
    expect(page).to have_field :spending_info_has_business_without_ein
    expect(page).to have_field :spending_info_has_business_no_business, checked: true
    expect(page).to have_no_field :spending_info_ready_true
    expect(page).to have_no_field :spending_info_ready_false
    # Not initially visible:
    expect(page).to have_no_field :spending_info_business_spending_usd
  end

  context 'for a couples account' do
    let(:couples?) { true }
    it 'asks for shared spending' do
      expect(page).to have_content 'combined monthly spending'
    end
  end
end
