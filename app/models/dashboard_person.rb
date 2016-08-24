# TODO fundamentally, this is a duplicate of the 'what survey pages can a user
# see and which page are they currently on?' logic which is duplicated
# elsewhere in the app. Definitely a possibility for some DRYing.
class DashboardPerson

  def initialize(person)
    @person = person
    raise "person must be persisted" unless @person.persisted?
  end

  def show_travel_plans_link?
    !onboarded_travel_plans?
  end

  def show_account_type_link?
    onboarded_travel_plans? && !onboarded_type?
  end

  def show_spending_link?
    onboarded_type? && eligible? && !onboarded_spending?
  end

  def show_cards_link?
    onboarded_spending? && !onboarded_cards?
  end

  def show_balances_link?
    onboarded_type? && (!eligible? || onboarded_cards?) && !onboarded_balances?
  end

  def show_readiness?
    onboarded_readiness?
  end

  def show_readiness_link?
    onboarded_balances? && eligible? && !(onboarded_readiness? && ready?)
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

  delegate :onboarded_travel_plans?, :onboarded_type?, to: :account
  delegate :account, :onboarded_spending?, :onboarded_cards?, :onboarded_balances?,
            :onboarded_readiness?, :eligible?, to: :person

end
