class SurveyController < NonAdminController
  def new
    @survey = current_user.build_survey
  end

  def create
    @survey = current_user.build_survey(survey_params)
    if @survey.save
      redirect_to survey_card_accounts_path
    else
      render "new"
    end
  end

  def new_card_accounts
    @cards = Card.all
  end

  def create_card_accounts
    cards = Card.where(id: params[:card_account][:card_ids])
    ActiveRecord::Base.transaction do
      CardAccount.unknown.create!(
        cards.map do |card|
          { user: current_user, card: card}
        end
      )
      current_user.survey.update_attributes!(has_added_cards: true)
    end
    redirect_to survey_balances_path
  end

  def new_balances
    @survey = BalancesSurvey.new(current_user)
  end

  def create_balances
    # Example params:
    # { balances: [{currency_id: 2, value: 100}, {currency_id: 6, value: 500}] }

    @survey = BalancesSurvey.new(current_user, balances_params)

    if @survey.save
      redirect_to root_path
    else
      render "new_balances"
    end
  end

  private

  def balances_params
    params.permit(balances: [:currency_id, :value]).fetch(:balances, [])
  end

  def survey_params
    params.require(:survey).permit(
      :first_name, :middle_names, :last_name, :whatsapp, :imessage, :time_zone,
      :text_message, :phone_number, :credit_score, :business_spending,
      :will_apply_for_loan, :personal_spending, :has_business, :citizenship
    )
  end

end
