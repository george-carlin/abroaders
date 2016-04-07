# A decorator object that wraps a card with additional methods to help
# when displaying it on the survey
class SurveyCard
  def initialize(card)
    @card = card
  end

  def self.all
    Card.survey.map { |card| new(card) }
  end

  def name
    parts = [@card.name, "- #{"$%.2f" % annual_fee}/yr"]
    unless bank_name == "American Express"
      # Amex will already be displayed as the bank name, so don't be redundant
      parts.insert(
        1,
        I18n.t("activerecord.attributes.card.networks.#{network}"),
      )
    end
    if business?
      parts.insert(1, "business")
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
