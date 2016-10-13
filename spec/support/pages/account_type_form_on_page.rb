require_relative "./object_on_page"

class AccountTypeFormOnPage < ObjectOnPage
  def dom_selector
    "[data-react-component='AccountTypeForm']"
  end

  button :solo,    "Sign up for solo earning"
  button :couples, "Sign up for couples earning"

  section :couples_form, ".CouplesForm"
  section :solo_form,    ".SoloForm"

  field :companion_first_name, :account_companion_first_name

  def submit_companion_first_name(name)
    fill_in_companion_first_name with: name
    click_couples_btn
  end

end
