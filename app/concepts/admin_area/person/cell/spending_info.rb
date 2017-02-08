module AdminArea
  module Person
    module Cell
      # model: a Person
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
