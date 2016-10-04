class Region < Destination
  validates :parent, absence: true

  # TODO: remove default_url as soon as we get real images
  has_attached_file :image, default_url: "/assets/slack_invite_bg.jpg"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/

  has_many :interest_regions, dependent: :destroy
  has_many :accounts, through: :interest_regions
end
