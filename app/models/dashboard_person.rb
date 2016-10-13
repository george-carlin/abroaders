# TODO replace me with a presenter (or remove me entirely)
class DashboardPerson

  def initialize(person)
    @person = person
    raise "person must be persisted" unless @person.persisted?
  end

  # TODO - update these methods to use the new OnboardingSurvey system
  def show_travel_plans_link?
    false
  end

  def show_account_type_link?
    false
  end

  def show_spending_link?
    false
  end

  def show_cards_link?
    false
  end

  def show_balances_link?
    false
  end
  # /TODO 

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

  delegate :account, :eligible?, to: :person

end
