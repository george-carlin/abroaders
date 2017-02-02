require 'rails_helper'

RSpec.describe AdminArea::HomeAirports::Cell::List do
  let(:cell) { described_class }

  it 'renders a list' do
    city = City.new(name: 'Townsville')
    airports = [
      Airport.new(name: 'Foo', code: 'FOO', city: city),
      Airport.new(name: 'Bar', code: 'BAR', city: city),
    ]
    rendered = cell.(airports).()
    expect(rendered).to eq '<ul><li>Foo (FOO)</li><li>Bar (BAR)</li></ul>'
  end
end
