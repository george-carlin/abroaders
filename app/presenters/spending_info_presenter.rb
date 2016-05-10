class SpendingInfoPresenter < ApplicationPresenter

  def monthly_spending_label
    "#{account.has_companion? ? "Shared" : "Personal"} spending"
  end

  def monthly_spending_usd
    h.number_to_currency(super)
  end

  def business_spending_usd
    h.number_to_currency(super)
  end

  def has_ein
    if has_business?
      if has_business_with_ein?
        "Has EIN"
      else
        "Does not have EIN"
      end
    end
  end

  def will_apply_for_loan
    super ? "Yes" : "No"
  end

end
