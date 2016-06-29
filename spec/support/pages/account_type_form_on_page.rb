require_relative "./object_on_page"

class AccountTypeFormOnPage < ObjectOnPage
  def dom_selector
    "[data-react-component='AccountTypeForm']"
  end

  button :confirm, "Submit"
  button :solo,    "Sign up for solo earning"
  button :couples, t("accounts.type.sign_up_for_couples_earning")

  section :couples_form, ".PartnerForm"
  section :solo_form,    ".SoloForm"

  field :partner_first_name,            :partner_account_partner_first_name
  field :couples_monthly_spending, :partner_account_monthly_spending_usd

  radio :partner_eligibility, :partner_account_eligibility, [:both, :person_0, :person_1, :neither]

  def show_partner_form_step_0?
    has_partner_first_name_field? &&
    has_couples_btn? &&
    has_no_partner_eligibility_radios? &&
    has_no_couples_monthly_spending_field?
  end

  def show_partner_form_step_1?
    has_no_partner_first_name_field? &&
    has_no_couples_btn? &&
    has_partner_eligibility_radios? &&
    has_couples_monthly_spending_field?
  end

end
