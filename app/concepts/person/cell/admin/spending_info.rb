require_dependency 'person/cell'
require_dependency 'person/cell/admin'

class Person::Cell::Admin::SpendingInfo < Trailblazer::Cell
  property :spending_info

  def show
    if spending_info
      cell(::SpendingInfo::Cell::Table, spending_info)
    else
      'User has not added their spending info'
    end
  end
end
