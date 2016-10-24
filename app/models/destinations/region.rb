class Region < Destination
  validates :parent, absence: true

  # Note that if you create Regions in development or testing that don't have
  # one of these codes, things will break because the PointsEstimateTable looks
  # up data from a CSV file containing hardcoded codes:
  CODES = %w(AC AF AS AU CA CB EU HA ME MX SA US).freeze

  # TODO: remove default_url as soon as we get real images
  has_attached_file :image, default_url: "/assets/slack_invite_bg.jpg"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/

  has_many :interest_regions, dependent: :destroy
  has_many :accounts, through: :interest_regions
end
