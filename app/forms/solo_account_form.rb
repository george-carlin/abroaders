class SoloAccountForm < Form
  attr_accessor :monthly_spending_usd

  attr_boolean_accessor :eligible_to_apply

  def self.name
    "SoloAccount"
  end

  def initialize(attributes={})
    attributes = attributes.with_indifferent_access
    if attributes[:eligible_to_apply].nil?
      self.eligible_to_apply = true
    else
      self.eligible_to_apply = attributes[:eligible_to_apply]
    end
  end

  validates :monthly_spending_usd,
    presence: true,
    numericality: { greater_than_or_equal_to: 0 },
    if: :eligible_to_apply?

  def save
    raise "not yet implemented"
  end

end
