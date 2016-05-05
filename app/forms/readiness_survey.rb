class ReadinessSurvey < ApplicationForm

  attr_accessor :main_passenger_unreadiness_reason, :companion_unreadiness_reason
  attr_boolean_accessor :main_passenger_ready, :companion_ready

  def initialize(account)
    # Sanity check:
    raise "invalid account" unless account.onboarding_stage == "readiness"
    @account = account
    @main_passenger_ready = true
    @companion_ready      = true
  end


  def has_companion?
    @account.has_companion?
  end

  def main_passenger_unready?
    !main_passenger_ready?
  end

  def companion_unready?
    !companion_ready?
  end

  def save
    super do
      ReadinessStatus.create!(
        passenger: @account.main_passenger,
        ready:     main_passenger_ready?,
        unreadiness_reason: main_passenger_unreadiness_reason
      )
      if has_companion?
        ReadinessStatus.create!(
          passenger: @account.companion,
          ready:     companion_ready?,
          unreadiness_reason: companion_unreadiness_reason
        )
      end
    end
  end

  validates :main_passenger_unreadiness_reason,
                absence: { unless: :main_passenger_unready? }
  validates :companion_unreadiness_reason,
                absence: { unless: :companion_unready? }

end
