require 'rails_helper'

RSpec.describe HomeAirports::Cell::Index, type: :view do
  def render_cell(model, options = {})
    described_class.(model, options.merge(context: CELL_CONTEXT)).()
  end

  # a user shouldn't be able to get through the onboarding survey without
  # adding at least one home airport, but handle the case any just in case (is
  # there legacy data with no HAs?) and for future-proofing.
  example '0 home airports' do
    cell = render_cell([])
    expect(cell).to have_content(
      "You have not told us what your home airport(s) are.",
    )
  end

  example 'only 1 home airport' do
    airport = create(:airport)

    cell = render_cell([airport])
    expect(cell).to have_content("You have told us that #{airport.full_name} is your home airport")
  end

  example '> 1 home airport' do
    airports = create_list(:airport, 3)

    cell = render_cell(airports)
    expect(cell).to have_content "You have told us that your home airports are"
    airports.each do |airport|
      expect(cell).to have_content airport.full_name
    end
  end
end
