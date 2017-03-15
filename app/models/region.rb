require 'csv'
require 'dry-struct'

require 'types'

class Region < Dry::Struct
  attribute :code, Types::Strict::String.constrained(format: /\A[A-Z]{2}\z/)
  attribute :name, Types::Strict::String

  def self.all
    @_all ||= begin
      csv_data = File.read(APP_ROOT.join('lib', 'data', 'regions.csv'))
      CSV.parse(csv_data).map { |row| new(name: row[0], code: row[1]) }
    end
  end

  def self.first
    all.first
  end

  def self.last
    all.last
  end

  def self.find_by_code(code)
    all.detect { |r| r.code == code }
  end

  def self.codes
    all.map(&:code)
  end

  # Note that if you create Regions in development or testing that don't have
  # one of these codes, things will break because the PointsEstimateTable looks
  # up data from a CSV file containing hardcoded codes:
  # CODES = %w(AC AF AS AU CA CB EU HA ME MX SA US).freeze
end
