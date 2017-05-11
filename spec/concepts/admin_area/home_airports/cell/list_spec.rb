require 'cells_helper'

RSpec.describe AdminArea::HomeAirports::Cell::List do
  it 'renders a list' do
    city = City.new(name: 'Townsville')
    airports = [
      Airport.new(name: 'Foo', code: 'FOO', city: city),
      Airport.new(name: 'Bar', code: 'BAR', city: city),
    ]
    expect(raw_cell(airports)).to eq "<ul>\n<li>Townsville Foo (FOO)</li>\n<li>Townsville Bar (BAR)</li>\n</ul>"
  end
end
