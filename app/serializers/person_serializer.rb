class PersonSerializer < ApplicationSerializer
  attributes :id, :first_name, :ready, :eligible, :owner, :spending_info

  has_one :spending_info

  always_include :spending_info
end
