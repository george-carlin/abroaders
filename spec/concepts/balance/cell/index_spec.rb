require 'rails_helper'

RSpec.describe Balance::Cell::Index, type: :view do
  let(:cell) { described_class }

  let(:account) { Account.new }
  let(:owner) { account.build_owner(id: 1, first_name: 'Erik') }

  def render_cell(result, opts = {})
    cell.(result, opts.merge(context: CELL_CONTEXT)).()
  end

  example 'subheaders and links for solo vs couple account' do
    # solo account doesn't have subheaders for the people's names:
    rendered = render_cell(
      'account' => account,
      'people_with_balances' => { owner => [] },
    )
    expect(rendered).not_to have_selector 'h2', text: "Erik's balances"
    expect(rendered).to have_link 'Add new'
    expect(rendered).not_to have_link "Add new balance for Erik"
    companion = account.build_companion(id: 5, first_name: 'Gabi')
    rendered = render_cell(
      'account' => account,
      'people_with_balances' => { owner => [], companion => [] },
    )
    expect(rendered).to have_selector 'h2', text: "Erik's balances"
    expect(rendered).to have_selector 'h2', text: "Gabi's balances"
    expect(rendered).not_to have_link(/\AAdd new\z/)
    expect(rendered).to have_link "Add new balance for Erik"
    expect(rendered).to have_link "Add new balance for Gabi"
  end

  example 'avoid XSS attacks' do
    currency = Currency.new(name: '<script>currency</script>')
    balances = [Balance.new(id: 123, value: 1, currency: currency)]
    companion = account.build_companion(id: 5, first_name: '<hacker>')
    rendered = render_cell(
      'account' => account,
      'people_with_balances' => { owner => balances, companion => [] },
    )
    expect(rendered).to include('&lt;script&gt;currency&lt;/script&gt;')
    expect(rendered).to include('&lt;hacker&gt;')
  end
end
