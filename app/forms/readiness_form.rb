class ReadinessForm < ApplicationForm
  attribute :account, Account
  attribute :who,     String

  def initialize(*_)
    super
    self.who = if owner.eligible? && companion.present? && companion.eligible?
                 'both'
               elsif owner.eligible?
                 'owner'
               elsif companion.present? && companion.eligible?
                 'companion'
               end
  end

  delegate :owner, :companion, to: :account

  WHO = %w[both owner companion neither].freeze

  private

  def persist!
    # TODO validate that 'who' makes sense given the presence/eligibility
    # of each person
    case who
    when "both"
      owner.update!(ready: true)
      companion.update!(ready: true)
    when "owner"
      owner.update!(ready: true)
    when "companion"
      companion.update!(ready: true)
    when "neither" # noop
    else
      raise 'unrecognized readiness update'
    end
  end
end
