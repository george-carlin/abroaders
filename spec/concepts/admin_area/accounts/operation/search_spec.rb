require 'rails_helper'

RSpec.describe AdminArea::Accounts::Operation::Search do
  let!(:accounts) do
    [
      create(:account, email: 'aaaaaa@example.com'),
      create(:account, email: 'bbbbbb@example.com'),
      create(:couples_account, email: 'ccccccc@example.com'),
      create(:account, email: 'ddddddd@example.com'),
    ]
  end

  before do
    accounts[0].owner.update!(first_name: 'George')
    accounts[1].owner.update!(first_name: 'Steve')
    accounts[2].owner.update!(first_name: 'Erik')
    accounts[2].companion.update!(first_name: 'Gabi')
    accounts[3].owner.update!(first_name: 'Erik')

    accounts[2].update!(onboarding_state: :phone_number)
    PhoneNumber::Operation::Create.(
      { phone_number: { number: '(555) 123-4567' } },
      'account' => accounts[2],
    )

    accounts[1].update!(onboarding_state: :phone_number)
    PhoneNumber::Operation::Create.(
      { phone_number: { number: '(555) 0001111' } },
      'account' => accounts[1],
    )
  end

  def search_for(query)
    described_class.(accounts: { search: query })['collection']
  end

  example 'search with no results' do
    expect(search_for('joiawjeroiajweroij')).to be_empty
  end

  example 'search by email' do
    expect(search_for('aaaaaa')).to eq [accounts[0]]
    expect(search_for('example.com')).to match_array accounts
  end

  example 'search by owner name' do
    expect(search_for('George')).to eq [accounts[0]]
  end

  example 'case insensitive search' do
    expect(search_for('geORge')).to eq [accounts[0]]
  end

  example 'search by companion name' do
    expect(search_for('Gabi')).to eq [accounts[2]]
  end

  example 'search by companion name case-insensitive' do
    expect(search_for('gaBI')).to eq [accounts[2]]
  end

  example 'search by phone number' do
    expect(search_for('555').pluck(:email)).to match_array accounts.values_at(1, 2).pluck(:email)
    expect(search_for('123').pluck(:email)).to eq [accounts[2].email]
  end

  example 'search returning multiple results' do
    expect(search_for('erik')).to match_array accounts.values_at(2, 3)
  end

  # example 'search by multiple attrs' do
  #   expect(search_for('erik gabi 555')).to eq [accounts[2]]
  # end
end
