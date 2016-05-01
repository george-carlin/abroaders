# See http://nithinbekal.com/posts/rails-presenters/
class PersonCardAccountsPresenter < Struct.new(:person, :view)

  def card_accounts_from_survey
    card_accounts.from_survey
  end

  def added_cards_in_survey?
    card_accounts_from_survey.any?
  end

  private

  def card_accounts
    @scope ||= person.card_accounts.includes(:card).order(:created_at)
  end


  #  scope = current_main_passenger\
  #                  .card_accounts.includes(:card).order(:created_at)
  #  @recommended_card_accounts = scope.recommended.load
  #  @unknown_card_accounts     = scope.unknown.load
  #  @applied_card_accounts     = scope.applied.load

  #    @p_recommended_card_accounts = partner_scope.recommended.load
  #    @p_unknown_card_accounts     = partner_scope.unknown.load
  #    @p_applied_card_accounts     = partner_scope.applied.load
  #  @other_card_accounts = scope.where.not(
  #    id: [
  #      @recommended_card_accounts + @unknown_card_accounts + \
  #      @applied_card_accounts
  #    ]
  #  )

end
