module AdminArea
  class BanksController < AdminController
    def index
      @banks = Bank.alphabetical
    end
  end
end
