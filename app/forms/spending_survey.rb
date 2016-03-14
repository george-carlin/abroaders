class SpendingSurvey < Form

  attr_accessor :main_spending_info, :companion_spending_info

  def initialize(main_passenger, companion=nil, params={})
    self.main_spending_info = main_passenger.build_spending_info

    if companion
      raise unless companion.is_a?(Passenger)
      self.companion_spending_info = companion.build_spending_info
    end
  end

end
