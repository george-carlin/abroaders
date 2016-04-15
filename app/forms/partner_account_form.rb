class PartnerAccountForm < Form
  attr_accessor :monthly_spending_usd, :partner_first_name, :eligibility

  def self.name
    "PartnerAccount"
  end

  ELIGIBILITY = %w[both person_0 person_1 neither]

  def initialize(attributes={})
    attributes = attributes.with_indifferent_access
    self.eligibility = attributes.fetch(:eligibility, "both")
  end

  def eligibility=(new_eligibility)
    new_el = new_eligibility.to_s
    unless ELIGIBILITY.include?(new_el)
      raise "unrecognized eligibility #{new_el}"
    end
    @eligibility = new_el
  end

  def neither_eligible_to_apply?
    eligibility == "neither"
  end

  validates :monthly_spending_usd,
    presence: true,
    numericality: { greater_than_or_equal_to: 0 },
    unless: :neither_eligible_to_apply?

  validates :partner_first_name,
    presence: true

  def save
    raise "not yet implemented"
  end

end
