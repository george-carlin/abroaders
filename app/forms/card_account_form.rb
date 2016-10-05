class CardAccountForm < ApplicationForm
  attribute :person_id, Person
  attribute :opened_year, String
  attribute :opened_month, String
  attribute :closed_year, String
  attribute :closed_month, String
  attribute :closed, Boolean

  def self.name
    "CardAccount"
  end

  def person
    Person.find(person_id)
  end

  def each_section
    Card.survey.group_by(&:bank).each do |bank, cards|
      yield bank, cards.group_by(&:bp)
    end
  end

  private

  def end_of_month(year, month)
    Date.parse("#{year}-#{month}-01").end_of_month
  end
end
