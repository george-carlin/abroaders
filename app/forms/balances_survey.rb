class BalancesSurvey
  attr_reader :balances, :errors

  def initialize(user, balances_params=nil)
    @user = user
    if balances_params
      # if the value they submitted is '0', or if they left the text field
      # empty, then don't create a Balance object, but don't make the whole
      # form submission fail. If they submitted a value that's less than 0,
      # then this is a validation error, so don't create anything, and show the
      # form again.
      balances_params.reject! do |balance|
        balance[:value].blank? || balance[:value].to_i == 0
      end
      @balances = @user.balances.build(balances_params).to_a
    else
      @balances = Currency.order("name ASC").map do |currency|
        @user.balances.build(currency: currency)
      end.to_a
    end
  end


  def save
    ApplicationRecord.transaction do
      if valid?
        @balances.each { |balance| balance.save(validate: false) }
        @user.survey.update_attributes!(has_added_balances: true)
        true
      else
        @errors = @balances.flat_map do |balance|
          balance.errors.full_messages.map do |message|
            "#{balance.currency_name} #{message.downcase}"
          end
        end
        # Build balances for other currencies so they appear on the form:
        Currency.all.each do |currency|
          unless @balances.find { |b| b.currency_id == currency.id }
            @balances.push(@user.balances.build(currency: currency))
          end
        end
        @balances.sort_by! { |b| b.currency_name }
        false
      end
    end
  end

  def valid?
    # Don't use 'all?' because we want to check *every* balance, so that every
    # invalid balance gets its error messages generated.
    result = true
    @balances.each { |b| result = false unless b.valid? }
    result
  end
end
