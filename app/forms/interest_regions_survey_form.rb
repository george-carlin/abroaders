class InterestRegionsSurveyForm < ApplicationForm
  attribute :account, Account
  attribute :regions, Array

  def self.name
    "InterestRegion"
  end

  def form_object
    [:survey, self]
  end

  private

  def persist!
    selected_regions_ids = []
    regions.each do |region|
      selected_regions_ids << region[:region_id].to_i if region[:selected]
    end

    selected_regions = ::Region.where(id: selected_regions_ids)
    account.regions_of_interest << selected_regions unless selected_regions.blank?
  end
end
