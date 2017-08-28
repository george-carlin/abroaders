require 'rails_helper'

RSpec.describe 'home airports survey', :js do
  let(:account) { create_account(:onboarded) }
  let(:person)  { account.owner }

  let!(:airports) { create_list(:airport, 5) }

  let(:old_has) { airports.first(2) }
  let(:new_has) { airports.last(2) }

  before do
    account.home_airports = old_has
    login_as_account account.reload
    visit edit_home_airports_path
  end

  let(:submit_form) { click_button('Save and continue') }

  subject { page }

  example 'updating HAs' do
    new_has.each do |airport|
      code = airport.code
      fill_in_typeahead('#typeahead', with: code, and_choose: code)
    end
    submit_form
    account.reload
    expect(account.home_airports).to match_array(new_has)
    expect(current_path).to eq home_airports_path
  end
end
