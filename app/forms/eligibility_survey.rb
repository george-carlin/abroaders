class EligibilitySurvey < ApplicationForm

  attribute :account,  Account
  attribute :eligible, String, default: "both"

  ELIGIBILITY = %w[both owner companion neither]

  def self.name
    "Eligibility"
  end

end
