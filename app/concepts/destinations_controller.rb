class DestinationsController < ApplicationController
  Destination::TYPES.each do |type|
    define_method type do
      destinations = load_destinations.send(type)

      respond_to do |f|
        f.csv do
          # Representable doesn't have a 'CSV' adapter, but use the JSON
          # representer to make sure that the .csv and the .json endpoints
          # both return data with the same keys
          data = represent(destinations).as_json
          keys = data.first.keys

          table = [keys, *data.map { |d| d.values_at(*keys) }]

          csv = CSV.generate { |gen| table.each { |row| gen << row } }
          render csv: csv, filename: type.pluralize
        end
        f.json do
          render json: represent(destinations).to_json
        end
      end
    end
  end

  private

  def load_destinations
    Destination.includes(:parent).order('name ASC')
  end

  def represent(destinations)
    Destination::Representer.for_collection.new(destinations)
  end
end
