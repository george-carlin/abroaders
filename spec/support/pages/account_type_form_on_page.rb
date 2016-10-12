require_relative "./object_on_page"

class AccountTypeFormOnPage < ObjectOnPage
  def dom_selector
    "[data-react-component='AccountTypeForm']"
  end

  button :confirm, "Submit"
  button :solo,    "Sign up for solo earning"
  button :couples, t("accounts.type.sign_up_for_couples_earning")

  section :couples_form, ".CouplesForm"
  section :solo_form,    ".SoloForm"

  field :companion_first_name,     :couples_account_companion_first_name
  field :couples_monthly_spending, :couples_account_monthly_spending_usd

  radio :companion_eligibility, :couples_account_eligibility, [:both, :person_0, :person_1, :neither]

  def submit_companion_first_name(name)
    fill_in_companion_first_name with: name
    click_couples_btn
  end

  def show_companion_form_step_0?
    has_companion_first_name_field? &&
      has_couples_btn? &&
      has_no_companion_eligibility_radios? &&
      has_no_couples_monthly_spending_field?
  end

  def show_companion_form_step_1?
    has_no_companion_first_name_field? &&
      has_no_couples_btn? &&
      has_companion_eligibility_radios? &&
      has_couples_monthly_spending_field?
  end
end
