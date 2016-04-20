# A decorator object that wraps a card with additional methods to help
# when displaying it on the survey
class SurveyCard
  def initialize(card)
    @card = card
  end

  def self.all
    Card.survey.map { |card| new(card) }
  end

  def annual_fee
    "#{"$%.2f" % @card.annual_fee}/yr"
  end

  def name
    parts = [@card.name]
    if business?
      parts.push("business")
    end
    unless bank_name == "American Express"
      # Amex will already be displayed as the bank name, so don't be redundant
      parts.push(I18n.t("activerecord.attributes.card.networks.#{network}"))
    end
    parts.join(" ")
  end

  def method_missing(symbol, *args)
    if @card.respond_to?(symbol)
      @card.send(symbol, *args)
    else
      super
    end
  end

end
