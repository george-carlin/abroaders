class UserStatusCSV

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

    def self.cols_for_rec_and_person(rec, person)
      date_format = "%D"

      [
        person.first_name,
        rec&.recommended_at&.strftime(date_format),
        rec&.seen_at&.strftime(date_format),
        rec&.clicked_at&.strftime(date_format),
        rec&.applied_at&.strftime(date_format),
        rec&.declined_at&.strftime(date_format),
        rec&.opened_at&.strftime(date_format),
        rec&.denied_at&.strftime(date_format),
        person.readiness_status&.created_at&.strftime("%D")
      ]
    end

    person_includes = [:card_accounts, :card_recommendations, :readiness_status, :spending_info]

    rows = Account.includes(
      people:    person_includes,
      owner:     person_includes,
      companion: person_includes,
    ).find_each.map do |account|
      row = [ account.email ]

      owner    = account.owner
      last_rec = owner.card_recommendations.order(created_at: :asc).first

      row = [ account.email ] + cols_for_rec_and_person(last_rec, owner)

      if account.has_companion?
        companion = account.companion
        last_rec  = companion.card_recommendations.order(created_at: :asc).first

        row += cols_for_rec_and_person(last_rec, companion)
      else
        row += [nil]*9
      end

      row += [
        account.created_at.strftime("%D"),
        account.onboarded?
      ]
    end

    rows.unshift(headers)

    CSV.generate { |csv| rows.each { |row| csv << row } }
  end
end
