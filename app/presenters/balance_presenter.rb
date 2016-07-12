class BalancePresenter < ApplicationPresenter

  def value
    h.number_with_delimiter super
  end

end
