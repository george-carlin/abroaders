class PersonSerializer < ApplicationSerializer
  attributes :id, :first_name, :ready, :eligible, :owner, :spending_info, :ready_on

  has_one :spending_info

  always_include :spending_info

  def ready_on
    object.ready_on.strftime("%m/%d/%y")
  end
end
