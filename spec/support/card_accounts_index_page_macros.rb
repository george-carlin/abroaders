module CardAccountsIndexPageMacros

  def card_account_selector(account)
    "##{dom_id(account)}"
  end

  def have_survey_cards_header(have=true)
    send("have_#{"no_" unless have}selector", "h2", text: "Other Cards")
  end

  def survey_cards_section
    "#card_accounts_from_survey"
  end

  def have_apply_btn(rec, have=true)
    send("have_#{"no_"unless have}link", "Apply", href: apply_card_account_path(rec))
  end

  def have_no_apply_btn(rec)
    have_apply_btn(rec, false)
  end

  def decline_btn(recommendation)
    "#card_recommendation_#{recommendation.id}_decline_btn"
  end

  def have_decline_btn(rec, have=true)
    send("have_#{"no_"unless have}selector", decline_btn(rec), text: "No Thanks")
  end

  def have_no_decline_btn(rec, have=true)
    have_decline_btn(rec, false)
  end

  def have_card_account(card_account)
    have_selector card_account_selector(card_account)
  end

end
