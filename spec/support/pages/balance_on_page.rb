require_relative "./record_on_page"

class BalanceOnPage < RecordOnPage
  alias balance model

  button :cancel
  button :edit
  button :save

  def update_value_to(value)
    click_edit_btn
    fill_in :balance_value, with: value
    click_save_btn
    wait_for_ajax
  end
end
