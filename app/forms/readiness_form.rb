class ReadinessForm < ApplicationForm
  attribute :account, Account
  attribute :who,     String, default: "both"

  WHO = {
    both: "both",
    owner: "owner",
    companion: "companion",
    neither: "neither"
  }

  private

  def persist!
    case who
    when WHO[:both]
      update_person!(account.owner)
      update_person!(account.companion, send_email: false)
    when WHO[:owner]
      update_person!(account.owner)
    when WHO[:companion]
      update_person!(account.companion)
    when WHO[:neither]
    else
      raise RuntimeError
    end
  end

  def update_person!(person, send_email: true)
    person.update!(ready: true)
    AccountMailer.notify_admin_of_user_readiness_update(account.id, Time.now.to_i).deliver_later if send_email
  end
end

