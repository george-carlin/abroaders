require 'rails_helper'

RSpec.describe Flight::Cell::Summary, type: :view do
  let(:cell) { described_class }

  class AirportNameStub
    def self.call(airport, *)
      airport.code
    end
  end

  example '#show' do
    airport_class = Struct.new(:name, :code)
    lhr = airport_class.new('Heathrow', 'LHR')
    jfk = airport_class.new('John F. Kennedy', 'JFK')
    # lhr = Struct.new(:from, :to)

    flight = Struct.new(:id, :from, :to).new(1, lhr, jfk)
    rendered = cell.(flight, airport_name_cell: AirportNameStub).()
    expect(rendered).to include 'LHR - JFK'
  end
end
