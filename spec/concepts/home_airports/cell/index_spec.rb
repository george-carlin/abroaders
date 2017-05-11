require 'cells_helper'

RSpec.describe HomeAirports::Cell::Index do
  controller HomeAirportsController

  let(:airport_class) { Struct.new(:full_name) }

  # a user shouldn't be able to get through the onboarding survey without
  # adding at least one home airport, but handle the case any just in case (is
  # there legacy data with no HAs?) and for future-proofing.
  example '0 home airports' do
    rendered = cell([]).()
    expect(rendered).to have_content(
      'You have not told us what your home airport(s) are.',
    )
  end

  example 'only 1 home airport' do
    airport = airport_class.new('Heathrow')

    rendered = cell([airport]).()
    expect(rendered).to have_content('You have told us that Heathrow is your home airport')
  end

  example '> 1 home airport' do
    airports = Array.new(2) { |i| airport_class.new("Airport #{i}") }

    rendered = cell(airports).()
    expect(rendered).to have_content 'You have told us that your home airports are'
    airports.each do |airport|
      expect(rendered).to have_content airport.full_name
    end
  end
end
