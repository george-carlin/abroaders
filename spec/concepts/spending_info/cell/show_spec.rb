require 'cells_helper'

RSpec.describe SpendingInfo::Cell::Show do
  controller SpendingInfosController

  let(:account) { Account.new(monthly_spending_usd: 1234) }
  let!(:owner)  { account.people.owner.build(id: 1, first_name: 'Erik') }

  def render_result(people)
    result = Trailblazer::Operation::Result.new(
      true,
      'account' => account,
      'people'  => people,
    )
    show(result)
  end

  example 'no eligible people' do
    expect { render_result([owner]) }.to raise_error RuntimeError
  end

  example 'solo account' do
    owner.eligible = true
    owner.build_spending_info(credit_score: 456)
    rendered = render_result([owner])

    expect(rendered).to have_content "Erik's Financials"
    expect(rendered).to have_content 'Personal spending:$1,234'
    expect(rendered).not_to have_content 'Shared spending'
    expect(rendered).to have_link 'Edit', href: edit_person_spending_info_path(owner)
  end

  context 'couples account' do
    let!(:companion) { account.people.companion.build(id: 2, first_name: 'Gabi') }
    # we need to stub this so that both account.people and account.companion
    # work as expected (without touching the DB)
    before { allow(account).to receive(:companion).and_return(companion) }

    example 'both people ineligible' do
      expect { render_result([owner, companion]) }.to raise_error RuntimeError
    end

    example 'both people eligible' do
      owner.eligible = true
      owner.build_spending_info(credit_score: 678)
      companion.eligible = true
      companion.build_spending_info(credit_score: 765)
      rendered = render_result([owner, companion])

      expect(rendered).to have_content "Erik's Financials"
      expect(rendered).to have_content "Gabi's Financials"
      expect(rendered).to have_content 'Shared spending:$1,234'
      expect(rendered).not_to have_content 'Personal spending'
      expect(rendered).to have_link 'Edit', href: edit_person_spending_info_path(owner)
      expect(rendered).to have_link 'Edit', href: edit_person_spending_info_path(companion)
    end

    example 'one person ineligible' do
      owner.eligible = true
      owner.build_spending_info(credit_score: 678)

      rendered = render_result([owner, companion])

      expect(rendered).to have_content "Erik's Financials"
      expect(rendered).to have_content "Gabi's Financials"
      expect(rendered).to have_content 'Shared spending:$1,234'
      expect(rendered).to have_content 'You told us that Gabi is not eligible'
      expect(rendered).to have_link 'Edit', href: edit_person_spending_info_path(owner)
      expect(rendered).not_to have_link 'Edit', href: edit_person_spending_info_path(companion)
    end
  end
end
