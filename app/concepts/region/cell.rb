class Region::Cell < Trailblazer::Cell
  property :id
  property :code
  property :name

  def image
    image_tag("regions/#{code}.jpg", class: 'region-image', style: 'width:100%')
  end

  def survey_checkbox_tag
    check_box_tag(
      'interest_regions_survey[region_ids][]',
      id,
      false,
      class: 'region-checkbox',
      id: "interest_regions_survey_region_ids_#{id}",
    )
  end

  def name_tag
    label_tag(
      "interest_regions_survey_region_ids_#{id}",
      name,
      class: 'region-name',
    )
  end
end
