module AdminArea
  module Person
    module Cell
      class SpendingInfo < Trailblazer::Cell
        property :spending_info

        def show
          if spending_info
            cell(::SpendingInfo::Cell::Table, spending_info)
          else
            'User has not added their spending info'
          end
        end
      end
    end
  end
end
