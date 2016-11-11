class SpendingInfoPresenter < ApplicationPresenter
  def monthly_spending_label
    "#{account.couples? ? 'Shared' : 'Personal'} spending"
  end

  def monthly_spending_usd
    h.number_to_currency(super)
  end

  def business_spending
    if has_business?
      h.content_tag :span, class: "spending-info-business-spending" do
        business_spending_usd +
          h.content_tag(:span, class: "has-ein") do
            "(#{has_ein})"
          end
      end
    else
      "No business"
    end
  end

  def business_spending_usd
    h.number_to_currency(super)
  end

  def has_ein
    return unless has_business?
    if has_business_with_ein?
      "Has EIN"
    else
      "Does not have EIN"
    end
  end

  def will_apply_for_loan
    super ? "Yes" : "No"
  end
end
