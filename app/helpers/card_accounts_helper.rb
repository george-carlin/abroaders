module CardAccountsHelper

  def options_for_card_account_status_select
    options_for_select(
      CardAccount.statuses.each_with_object({}) do |(status, _), hash|
        hash[status.humanize] = status
      end
    )
  end

end
