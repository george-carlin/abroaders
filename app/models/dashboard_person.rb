class DashboardPerson

  def initialize(person)
    @person = person
    raise "person must be persisted" unless @person.persisted?
  end

  def show_travel_plans_link?
    !account.onboarded_travel_plans?
  end

  def show_account_type_link?
    !show_travel_plans_link? && !account.onboarded_type?
  end

  def show_spending_link?
    !show_account_type_link? && eligible? && !person.onboarded_spending?
  end

  def show_cards_link?
    !show_spending_link? && eligible? && !person.onboarded_cards?
  end

  def show_balances_link?
    !show_cards_link? && !person.onboarded_balances?
  end

  def show_readiness?
    person.readiness_given?
  end

  def show_readiness_link?
    !show_balances_link? && !(person.readiness_given? && person.ready_to_apply?)
  end

  def method_missing(meth, *args, &block)
    if @person.respond_to?(meth)
      @person.send(meth, *args, &block)
    else
      super
    end
  end

  def to_param
    person.id.to_s
  end

  private

  attr_reader :person

  def eligible?
    person.eligible_to_apply?
  end

  def account
    @person.account
  end

end
