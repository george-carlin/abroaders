class PersonPresenter < ApplicationPresenter
  # The person signed up on the date their *account* was created, not on the
  # date which they added their passenger info in the survey. (In practice this
  # will usually be on the same date anyway, but bear it in mind.)
  def signed_up
    account.created_at.strftime("%D")
  end

  delegate :email, :phone_number, to: :account

  def eligibility
    if onboarded_eligibility?
      eligible? ? "Yes" : "No"
    else
      "Unknown"
    end
  end

  def readiness
    if ready.nil?
      "Unknown"
    elsif ready?
      "Ready"
    else
      "Not ready"
    end
  end
end
