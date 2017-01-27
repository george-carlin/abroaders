require 'rails_helper'

RSpec.describe 'view home airports page' do
  include_context 'logged in'
  let!(:airports) { create_list(:airport, 2) }
  let!(:other_airport) { create(:airport) }

  before do
    account.home_airports << airports
    visit home_airports_path
  end

  it 'lists my home airports' do
    airports.each do |airport|
      expect(page).to have_content airport.full_name
    end
    expect(page).not_to have_content other_airport.full_name
  end
end
