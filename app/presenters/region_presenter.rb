class RegionPresenter < ApplicationPresenter
  def image
    h.image_tag("regions/#{code}.jpg", class: 'region-image', style: 'width:100%')
  end

  def survey_checkbox_tag
    h.check_box(
      :interest_regions_survey,
      'region_ids][]',
      class: 'region-checkbox',
      value: region.id,
    )
  end
end
