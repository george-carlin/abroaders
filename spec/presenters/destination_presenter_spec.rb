require 'rails_helper'

describe DestinationPresenter do
  example '#name' do
    country   = Country.new(name: "England")
    presenter = described_class.new(country, OpenStruct.new)
    expect(presenter.name).to eq "England"
    city    = City.new(name: "London")
    airport = Airport.new(parent: city, name: "Heathrow", code: "LHR")
    presenter = described_class.new(airport, OpenStruct.new)
    expect(presenter.name).to eq "London (LHR)"
  end
end
