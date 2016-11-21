class PersonPresenter < ApplicationPresenter
  # The person signed up on the date their *account* was created, not on the
  # date which they added their passenger info in the survey. (In practice this
  # will usually be on the same date anyway, but bear it in mind.)
  def signed_up
    account.created_at.strftime("%D")
  end

  delegate :email, to: :account

  def phone_number
    account.phone_number&.number
  end

  def eligibility
    if eligible?
      "Yes"
    else
      eligible.nil? ? "Unknown" : "No"
    end
  end

  def readiness
    ready ? "Ready" : "Not ready"
  end
end
