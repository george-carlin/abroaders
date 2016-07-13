class UserStatusCSV

  DATE_FORMAT = "%D"

  def self.generate
    # Copy and paste this shitty code into the rails console on Heroku to print
    # out some CSV data that Erik can use:

    headers = [
      "email",
      "own_name",
      "own_recommended_at",
      "own_seen_at",
      "own_clicked_at",
      "own_applied_at",
      "own_declined_at",
      "own_opened_at",
      "own_denied_at",
      "own_ready_at",
      "com_name",
      "com_recommended_at",
      "com_seen_at",
      "com_clicked_at",
      "com_applied_at",
      "com_declined_at",
      "com_opened_at",
      "com_denied_at",
      "com_ready_at",
      "signed_up_at",
      "onboarded",
    ]

    person_includes = [:card_accounts, :card_recommendations, :readiness_status, :spending_info]

    rows = Account.includes(
      people:    person_includes,
      owner:     person_includes,
      companion: person_includes,
    ).find_each.map do |account|
      owner_columns = generate_columns_for_person(account.owner)

      row = [ account.email ] + owner_columns

      if account.has_companion?
        row += generate_columns_for_person(account.companion)
      else
        row += [nil] * owner_columns.length
      end

      row += [
        account.created_at.strftime("%D"),
        account.onboarded?
      ]
    end

    rows.unshift(headers)

    CSV.generate { |csv| rows.each { |row| csv << row } }
  end

  def self.generate_columns_for_person(person)
    rec = person.card_recommendations.order(created_at: :desc).first
    [
      person.first_name,
      rec&.recommended_at&.strftime(DATE_FORMAT),
      rec&.seen_at&.strftime(DATE_FORMAT),
      rec&.clicked_at&.strftime(DATE_FORMAT),
      rec&.applied_at&.strftime(DATE_FORMAT),
      rec&.declined_at&.strftime(DATE_FORMAT),
      rec&.opened_at&.strftime(DATE_FORMAT),
      rec&.denied_at&.strftime(DATE_FORMAT),
      person.readiness_status&.created_at&.strftime("%D")
    ]
  end

end
