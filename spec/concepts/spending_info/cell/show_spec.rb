require 'cells_helper'

RSpec.describe SpendingInfo::Cell::Show do
  controller SpendingInfosController

  let(:account) { create_account(monthly_spending_usd: 1234) }
  let!(:owner)  { account.owner }

  example 'no eligible people' do
    expect { cell(account).() }.to raise_error RuntimeError
  end

  example 'solo account' do
    owner.update!(eligible: true)
    owner.create_spending_info!(credit_score: 456, has_business: 'no_business')
    rendered = cell(account.reload).()

    expect(rendered).to have_content "Erik's Financials"
    expect(rendered).to have_content 'Personal spending:$1,234'
    expect(rendered).not_to have_content 'Shared spending'
    expect(rendered).to have_link 'Edit', href: edit_person_spending_info_path(owner)
  end

  context 'couples account' do
    let!(:companion) { account.create_companion!(first_name: 'Gabi', eligible: false) }

    example 'both people ineligible' do
      expect { cell(account).() }.to raise_error RuntimeError
    end

    example 'both people eligible' do
      owner.update!(eligible: true)
      owner.create_spending_info!(credit_score: 678, has_business: 'no_business')
      companion.update!(eligible: true)
      companion.create_spending_info!(credit_score: 765, has_business: 'no_business')
      rendered = cell(account.reload).()

      expect(rendered).to have_content "Erik's Financials"
      expect(rendered).to have_content "Gabi's Financials"
      expect(rendered).to have_content 'Shared spending:$1,234'
      expect(rendered).not_to have_content 'Personal spending'
      expect(rendered).to have_link 'Edit', href: edit_person_spending_info_path(owner)
      expect(rendered).to have_link 'Edit', href: edit_person_spending_info_path(companion)
    end

    example 'one person ineligible' do
      owner.update!(eligible: true)
      owner.create_spending_info!(credit_score: 678, has_business: 'no_business')

      rendered = cell(account.reload).()

      expect(rendered).to have_content "Erik's Financials"
      expect(rendered).to have_content "Gabi's Financials"
      expect(rendered).to have_content 'Shared spending:$1,234'
      expect(rendered).to have_content 'You told us that Gabi is not eligible'
      expect(rendered).to have_link 'Edit', href: edit_person_spending_info_path(owner)
      expect(rendered).not_to have_link 'Edit', href: edit_person_spending_info_path(companion)
    end
  end
end
