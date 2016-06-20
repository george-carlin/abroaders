class PartnerAccountForm < AccountTypeForm
  attr_accessor :account, :monthly_spending_usd, :partner_first_name, :eligibility
  attr_reader :person_0, :person_1

  def self.name
    "PartnerAccount"
  end

  ELIGIBILITY = %w[both person_0 person_1 neither]

  def initialize(attributes={})
    assign_attributes(attributes)

    # Set default:
    self.eligibility = "both" if self.eligibility.nil?
  end

  def eligibility=(new_eligibility)
    new_el = new_eligibility.to_s
    unless ELIGIBILITY.include?(new_el)
      raise "unrecognized eligibility #{new_el}"
    end
    @eligibility = new_el
  end

  def person_0_eligible_to_apply?
    %w[both person_0].include?(eligibility)
  end

  def person_1_eligible_to_apply?
    %w[both person_1].include?(eligibility)
  end

  def neither_eligible_to_apply?
    eligibility == "neither"
  end

  validates :monthly_spending_usd,
    presence: true,
    numericality: { greater_than_or_equal_to: 0 },
    unless: :neither_eligible_to_apply?

  validates :partner_first_name, presence: true

  private

  def persist!
    account.update_attributes!(
      monthly_spending_usd: monthly_spending_usd,
      onboarded_type:       true,
    )
    @person_0 = account.people.first
    if person_0_eligible_to_apply?
      person_0.eligible_to_apply!
    else
      person_0.ineligible_to_apply!
    end
    @person_1 = account.create_companion!(first_name: partner_first_name)
    if person_1_eligible_to_apply?
      person_1.eligible_to_apply!
    else
      person_1.ineligible_to_apply!
    end

    track_intercom_event!
  end

end
