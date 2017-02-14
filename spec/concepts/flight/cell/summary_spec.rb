require 'cells_helper'

require 'flight/cell/summary'

RSpec.describe Flight::Cell::Summary do
  class AirportNameStub
    def self.call(airport, *)
      airport.name
    end
  end

  example '#show' do
    airport_class = Struct.new(:name)
    lhr = airport_class.new('Heathrow')
    jfk = airport_class.new('John F. Kennedy')
    # lhr = Struct.new(:from, :to)

    flight = Struct.new(:id, :from, :to).new(1, lhr, jfk)
    rendered = show(flight, airport_name_cell: AirportNameStub)
    expect(rendered.to_s).to include 'Heathrow - John F. Kennedy'
  end
end
