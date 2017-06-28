module AdminArea
  class BanksController < AdminController
    def index
      render cell(Banks::Cell::Index, Bank.alphabetical)
    end
  end
end
