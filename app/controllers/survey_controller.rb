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
    @balances = Currency.order("name ASC").map do |currency|
      current_user.balances.build(currency: currency)
    end
  end

  def create_balances
    # Example params:
    # { balances: [{currency_id: 2, value: 100}, {currency_id: 6, value: 500}] }

    # TODO this is ugly as hell. Extract to a form object.

    balances_params = params.permit(
      balances: [:currency_id, :value]
    ).fetch(:balances, []).reject do |balance|
      # if the value they submitted is '0', or if they left the text field
      # empty, then don't create a Balance object, but don't make the whole
      # form submission fail. If they submitted a value that's less than 0,
      # then this is a validation error, so don't create anything, and show
      # the form again.
      balance[:value].blank? || balance[:value].to_i == 0
    end || []

    ApplicationRecord.transaction do
      @balances = current_user.balances.build(balances_params).to_a
      if @balances.all?(&:valid?)
        @balances.each { |balance| balance.save(validate: false) }
        current_user.survey.update_attributes!(has_added_balances: true)
        redirect_to root_path
      else
        @errors = @balances.flat_map do |balance|
          balance.errors.full_messages.map do |message|
            "#{balance.currency_name} #{message.downcase}"
          end
        end
        # Build remaining balances so they'll appear on the form
        Currency.all.each do |currency|
          unless @balances.find { |b| b.currency_id == currency.id }
            @balances.push(current_user.balances.build(currency: currency))
          end
        end
        @balances.sort_by! { |b| b.currency_name }
        render "new_balances"
      end
    end
  end

  private

  def survey_params
    params.require(:survey).permit(
      :first_name, :middle_names, :last_name, :whatsapp, :imessage, :time_zone,
      :text_message, :phone_number, :credit_score, :business_spending,
      :will_apply_for_loan, :personal_spending, :has_business, :citizenship
    )
  end

end
