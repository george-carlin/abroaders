class RegionPresenter < ApplicationPresenter
  def image
    h.image_tag("regions/#{code}.jpg", class: 'region-image', style: 'width:100%')
  end

  def survey_checkbox_tag
    h.check_box_tag(
      'interest_regions_survey[region_ids][]',
      region.id,
      false,
      class: 'region-checkbox',
      id: "interest_regions_survey_region_ids_#{region.id}",
    )
  end

  def name_tag
    h.label_tag(
      "interest_regions_survey_region_ids_#{region.id}",
      name,
      class: 'region-name',
    )
  end
end
