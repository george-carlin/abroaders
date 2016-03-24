class ReadinessSurvey < Form

  attr_accessor :main_passenger_unreadiness_reason, :companion_unreadiness_reason
  attr_reader   :main_passenger_ready, :companion_ready

  alias_method :main_passenger_ready?, :main_passenger_ready
  alias_method :companion_ready?,      :companion_ready

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

  # TODO DRY me
  def main_passenger_ready=(bool)
    @main_passenger_ready = %w[false 0].include?(bool) ? false : !!bool
  end

  # TODO DRY me
  def companion_ready=(bool)
    @companion_ready = %w[false 0].include?(bool) ? false : !!bool
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
      @account.onboarded!
    end
  end

  validates :main_passenger_unreadiness_reason,
                absence: { unless: :main_passenger_unready? }
  validates :companion_unreadiness_reason,
                absence: { unless: :companion_unready? }

end
