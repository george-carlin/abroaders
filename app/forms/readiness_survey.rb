class ReadinessSurvey < ReadinessForm
  attribute :owner_unreadiness_reason,     String
  attribute :companion_unreadiness_reason, String

  def self.name
    "ReadinessSurvey"
  end

  private

  def persist!
    super

    if owner.unready && owner_unreadiness_reason
      owner.update!(unreadiness_reason: owner_unreadiness_reason)
    end

    if companion && companion.unready && companion_unreadiness_reason
      companion.update!(unreadiness_reason: companion_unreadiness_reason)
    end

    flow = OnboardingFlow.build(account)
    flow.add_readiness!
    account.update!(onboarding_state: flow.workflow_state)
  end
end
