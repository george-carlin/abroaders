class CardAccountsController < NormalUserController

  def onboarding
    @grouped_cards = Card.all.group_by(&:bank)\
                          .each_with_object({}) do |(bank, cards), hash|
      hash[bank] = cards.group_by(&:bp)
    end

    # @grouped_cards is now a hash with the following format:
    # 
    # {
    #   "chase" => {
    #     "business" => [<Card>, <Card>, <Card>],
    #     "personal" => [<Card>, <Card>, <Card>]
    #   }
    #   "citibank" => {
    #     "business" => [<Card>, <Card>, <Card>],
    #     "personal" => [<Card>, <Card>, <Card>]
    #   },
    #   ... etc ...
    # }
    #
  end

end
