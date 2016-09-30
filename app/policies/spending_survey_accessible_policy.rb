class SpendingSurveyAccessiblePolicy
  def initialize(account)
    @account = account
  end

  # return true iff the given account can access the spending survey page
  def accessible?
    owner = @account.owner
    bool  = owner.eligible? && !owner.onboarded_spending?

    if companion = @account.companion
      bool &&= companion.eligible? && !companion.onboarded_spending?
    end

    bool
  end

end
