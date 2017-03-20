require 'cells_helper'

RSpec.describe Account::Cell::Dashboard do
  controller ApplicationController

  let(:account) { Account.new }
  let!(:owner)     { account.build_owner(id: 1, first_name: 'Erik', last_recommendations_at: Time.zone.now) }
  let!(:companion) { account.build_companion(id: 2, first_name: 'Gabi') }

  example 'rendering' do
    rendered = show(
      'account' => account,
      'people'  => [owner, companion],
      'travel_plans' => [],
      'unresolved_recommendations' => [],
    )

    # owner selector goes before companion selector:
    expect(rendered).to have_selector "#person_#{owner.id} + #person_#{companion.id}"
    # has no modal because there are no unresolved_recommendations
    expect(rendered).not_to have_selector '.modal'
  end

  example 'with "unresolved recs" modal' do
    rendered = show(
      'account' => account,
      'people'  => [owner, companion],
      'travel_plans' => [],
      'unresolved_recommendations' => [Object.new],
    )

    expect(rendered).to have_selector '.modal'
    expect(rendered).to have_content(
      'You have card recommendations that require immediate action',
    )
    expect(rendered).to have_link 'Continue', href: cards_path
  end

  example 'unresolved recs modal hidden by cookie' do
    rendered = show(
      {
        'account' => account,
        'people'  => [owner, companion],
        'travel_plans' => [],
        'unresolved_recommendations' => [Object.new],
      },
      recommendation_timeout: true,
    )

    expect(rendered).not_to have_selector '.modal'
    expect(rendered).not_to have_link 'Continue'
  end
end
