class ReadinessForm < ApplicationForm
  attribute :account, Account
  attribute :who,     String, default: "both"

  WHO = {
    both: "both",
    owner: "owner",
    companion: "companion",
    neither: "neither"
  }

  def owner
    @owner ||= account.owner
  end

  def companion
    @companion ||= account.companion
  end

  private

  def persist!
    case who
    when WHO[:both]
      owner.update!(ready: true)
      companion.update!(ready: true)
    when WHO[:owner]
      owner.update!(ready: true)
    when WHO[:companion]
      companion.update!(ready: true)
    when WHO[:neither]
    else
      raise RuntimeError
    end
  end
end

