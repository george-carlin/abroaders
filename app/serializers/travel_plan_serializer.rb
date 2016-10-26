class TravelPlanSerializer < ApplicationSerializer
  attributes :id, :type, :depart_on, :return_on,
             :no_of_passengers, :further_information, :acceptable_classes

  has_many :flights

  always_include :flights

  def depart_on
    object.depart_on&.strftime("%D")
  end

  def return_on
    object.return_on&.strftime("%D")
  end

  def acceptable_classes
    acceptable_classes = []
    if object.acceptable_classes.any?
      acceptable_classes << "E"   if object.will_accept_economy?
      acceptable_classes << "PE"  if object.will_accept_premium_economy?
      acceptable_classes << "B"   if object.will_accept_business_class?
      acceptable_classes << "1st" if object.will_accept_first_class?
    else
      acceptable_classes << "None given"
    end

    acceptable_classes.join(", ")
  end
end
