module Person::EligibleToApply
  extend ActiveSupport::Concern

  included do
    has_one :eligibility
  end

  def eligible_to_apply!
    build_eligibility(eligible: true)
    eligibility.save! if persisted?
  end

  def eligibility_given?
    !!eligibility&.persisted?
  end

  def ineligible_to_apply!
    build_eligibility(eligible: false)
    eligibility.save! if persisted?
  end

  def onboarded_eligibility?
    eligibility.present?
  end

  def eligible_to_apply?
    !!eligibility&.eligible?
  end

  def ineligible_to_apply?
    !eligible_to_apply?
  end
end
