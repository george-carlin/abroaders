module AdminArea
  module Person
    module Cell
      # TODO this cell sucks
      #
      # @!method self.call(model, opts = {})
      #   @param [Person] model
      class SpendingInfo < Trailblazer::Cell
        property :spending_info

        def show
          if spending_info.nil?
            'User has not added their spending info'
          else
            cell(::SpendingInfo::Cell::Table, spending_info).() + \
              link_to('Edit', edit_admin_person_spending_info_path(model))
          end
        end
      end
    end
  end
end
