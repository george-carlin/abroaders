require 'rails_helper'

RSpec.describe 'new recommendation request page' do
  # will raise an error if the account has no monthly spending saved:
  let(:account) { create(:account, :eligible, :onboarded, monthly_spending_usd: 1234) }
  let(:owner)   { account.owner }

  before do
    create(:spending_info, person: owner, credit_score: 567, has_business: 'no_business')
    login_as account
  end

  context 'solo account' do
    before { visit new_recommendation_requests_path(person_type: :owner) }

    example 'submitting request' do
      click_button 'Submit Request'
      owner.reload
      expect(owner.unresolved_recommendation_request?).to be true
    end

    example 'solo account - viewing my data' do
      visit new_recommendation_requests_path(person_type: :owner)
      expect(page).to have_content 'Is your personal monthly spending still $1,234.00?'
      expect(page).to have_content 'Is your credit score still 567?'
      expect(page).to have_content 'Do you have a business?'
      expect(page).to have_content "You told us that you don't have a business"
    end

    describe 'confirming/updating my data', :js do
      before { visit new_recommendation_requests_path(person_type: :owner) }

      let(:credit_score_section) { "#confirm_person_#{owner.id}_credit_score" }
      let(:business_section) { "#confirm_person_#{owner.id}_business_spending" }

      example 'confirming personal spending' do
        within '#confirm_personal_spending' do
          click_button 'Yes'
        end
        expect(page).not_to have_content 'Is your personal monthly spending'
        expect(page).to have_content 'Confirmed!'
      end

      example 'updating personal spending' do
        expect(page).to have_no_field :spending_info_monthly_spending_usd
        within '#confirm_personal_spending' do
          click_button 'No'
          # back and forth
          expect(page).to have_field :spending_info_monthly_spending_usd
          click_button 'Go back'
          expect(page).to have_no_field :spending_info_monthly_spending_usd
          click_button 'No'
          fill_in :spending_info_monthly_spending_usd, with: 9999
          click_button 'Save'
        end
        expect(page).to have_content 'Updated!'
        expect(account.reload.monthly_spending_usd).to eq 9999
      end

      example 'confirming credit score' do
        within credit_score_section do
          click_button 'Yes'
        end
        expect(page).not_to have_content 'Is your credit score'
        expect(page).to have_content 'Confirmed!'
      end

      example 'updating credit score' do
        expect(page).to have_no_field :spending_info_credit_score
        within credit_score_section do
          click_button 'No'
          # back and forth
          expect(page).to have_field :spending_info_credit_score
          click_button 'Go back'
          expect(page).to have_no_field :spending_info_credit_score
          click_button 'No'
          fill_in :spending_info_credit_score, with: 587
          click_button 'Save'
        end
        expect(page).to have_content 'Updated!'
        expect(owner.spending_info.reload.credit_score).to eq 587
      end

      example 'confirming business spending' do
        within business_section do
          click_button 'Yes'
        end
        expect(page).not_to have_content 'Do you have a business'
        expect(page).to have_content 'Confirmed!'
      end

      example 'updating business spending' do
        expect(page).to have_no_selector '.confirm_business_spending_radio'
        within business_section do
          click_button 'No'
          # back and forth
          expect(page).to have_selector '.confirm_business_spending_radio', count: 3
          click_button 'Go back'
          expect(page).to have_no_selector '.confirm_business_spending_radio'
          click_button 'No'
          choose 'Yes, with an EIN (Employer ID Number)'
          fill_in :spending_info_business_spending_usd, with: 888
          click_button 'Save'
        end
        expect(page).to have_content 'Updated!'
        owner.spending_info.reload
        expect(owner.spending_info.has_business).to eq 'with_ein'
        expect(owner.spending_info.business_spending_usd).to eq 888
      end
    end
  end

  context 'couples account' do
    let(:companion) { create(:companion, :eligible, account: account) }

    before do
      create(
        :spending_info,
        business_spending_usd: 432,
        credit_score: 579,
        has_business: 'with_ein',
        person: companion,
      )
      account.reload
    end

    example 'submitting request' do
      visit new_recommendation_requests_path(person_type: :both)
      click_button 'Submit Request'
      expect(owner.unresolved_recommendation_request?).to be true
      expect(companion.unresolved_recommendation_request?).to be true
    end

    example 'viewing data for both' do
      visit new_recommendation_requests_path(person_type: :both)
      expect(page).to have_content "Is your personal monthly spending still $1,234.00?"
      expect(page).to have_content "Is Erik's credit score still 567?"
      expect(page).to have_content "Is Gabi's credit score still 579?"
      expect(page).to have_content 'Does Erik have a business?'
      expect(page).to have_content "You told us that Erik doesn't have a business"
      expect(page).to have_content 'Does Gabi have a business?'
      expect(page).to have_content(
        "You told us that Gabi has a business with an EIN (Employer ID "\
        "Number) and that the business spends, on average, $432.00 a month.",
      )
    end

    example 'viewing data for owner only' do
      visit new_recommendation_requests_path(person_type: :owner)
      expect(page).to have_content "Is your personal monthly spending still $1,234.00?"
      expect(page).to have_content "Is Erik's credit score still 567?"
      expect(page).to have_no_content "Gabi's credit score"
      expect(page).to have_content 'Does Erik have a business?'
      expect(page).to have_content "You told us that Erik doesn't have a business"
      expect(page).to have_no_content 'Does Gabi have a business?'
      expect(page).to have_no_content 'Gabi has a business with an EIN'
    end

    example 'viewing data for companion only' do
      visit new_recommendation_requests_path(person_type: :companion)
      expect(page).to have_content "Is your personal monthly spending still $1,234.00?"
      expect(page).to have_no_content "Erik's credit score"
      expect(page).to have_content "Is Gabi's credit score still 579?"
      expect(page).to have_no_content 'Erik have a business?'
      expect(page).to have_no_content "Erik doesn't have a business"
      expect(page).to have_content 'Does Gabi have a business?'
      expect(page).to have_content(
        "You told us that Gabi has a business with an EIN (Employer ID "\
        "Number) and that the business spends, on average, $432.00 a month.",
      )
    end

    describe 'confirming/updating my data', :js do
      before { visit new_recommendation_requests_path(person_type: :owner) }

      example 'confirming personal spending' do
        within '#confirm_personal_spending' do
          click_button 'Yes'
        end
        expect(page).not_to have_content 'Is your personal monthly spending'
        expect(page).to have_content 'Confirmed!'
      end

      example 'updating personal spending' do
        expect(page).to have_no_field :spending_info_monthly_spending_usd
        within '#confirm_personal_spending' do
          click_button 'No'
          # back and forth
          expect(page).to have_field :spending_info_monthly_spending_usd
          click_button 'Go back'
          expect(page).to have_no_field :spending_info_monthly_spending_usd
          click_button 'No'
          fill_in :spending_info_monthly_spending_usd, with: 9999
          click_button 'Save'
        end
        expect(page).to have_content 'Updated!'
        expect(account.reload.monthly_spending_usd).to eq 9999
      end

      pending 'confirming credit score'

      pending 'updating credit score'

      pending 'confirming business spending'

      pending 'updating business spending'
    end
  end

  # TODO what happens if they have the conf. survey open in two tabs and click 'Save' twice?
end
