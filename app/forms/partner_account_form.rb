class PartnerAccountForm < AccountTypeForm
  # TODO convert me to use Virtus
  attr_accessor :account, :monthly_spending_usd, :partner_first_name, :eligibility, :phone_number
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

  def person_0_eligible?
    %w[both person_0].include?(eligibility)
  end

  def person_1_eligible?
    %w[both person_1].include?(eligibility)
  end

  def neither_eligible?
    eligibility == "neither"
  end

  validates :monthly_spending_usd,
    presence: true,
    numericality: { greater_than_or_equal_to: 0 },
    unless: :neither_eligible?

  validates :partner_first_name, presence: true

  private

  def persist!
    account.monthly_spending_usd = monthly_spending_usd
    account.onboarded_type       = true
    account.phone_number = phone_number.strip if phone_number.present?
    account.save!
    @person_0 = account.people.first
    @person_0.update_attributes!(eligible: person_0_eligible?)
    @person_1 = account.create_companion!(
      eligible:   person_1_eligible?,
      first_name: partner_first_name,
    )
    track_intercom_event!
  end

end
