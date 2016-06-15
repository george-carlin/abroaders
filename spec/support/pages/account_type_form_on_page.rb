require_relative "./object_on_page"

class AccountTypeFormOnPage < ObjectOnPage
  def dom_selector
    "[data-react-component=AccountTypeForm]"
  end

  button :confirm, "Submit"
  button :solo,    "Sign up for solo earning"
  button :couples, t("accounts.type.sign_up_for_couples_earning")

  section :couples_form, ".PartnerForm"
  section :solo_form,    ".SoloForm"

end
