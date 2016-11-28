class InterestRegionsSurvey < ApplicationForm
  attribute :account,    Account
  attribute :region_ids, Array[Integer]

  def form_object
    [:survey, self]
  end

  private

  def persist!
    selected_regions = ::Region.where(id: region_ids)
    account.regions_of_interest << selected_regions unless selected_regions.blank?
    Account::Onboarder.new(account).add_regions_of_interest!
  end
end
