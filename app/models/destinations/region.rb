class Region < Destination
  validates :parent, absence: true

  # Note that if you create Regions in development or testing that don't have
  # one of these codes, things will break because the PointsEstimateTable looks
  # up data from a CSV file containing hardcoded codes:
  CODES = %w(AC AF AS AU CA CB EU HA ME MX SA US).freeze

  has_many :interest_regions, dependent: :destroy
  has_many :accounts, through: :interest_regions
end
