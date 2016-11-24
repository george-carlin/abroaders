class Person::Cell < Trailblazer::Cell
  module Admin
    # Hack to prevent annoying autoload error. See Rails issue #14844
    autoload :SpendingInfo, 'person/cell/admin/spending_info'
  end
end
