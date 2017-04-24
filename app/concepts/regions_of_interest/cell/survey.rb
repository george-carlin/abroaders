module RegionsOfInterest
  module Cell
    # @!method self.call(regions)
    #   @param regions [Collection<Region>]
    class Survey < Abroaders::Cell::Base
      def title
        'Regions of Interest'
      end

      private

      def regions
        cell(RegionInput, collection: model)
      end

      # @!method self.call(region)
      #   @param region [Region]
      class RegionInput < Abroaders::Cell::Base
        def show
          <<-HTML
            <div class="col-xs-12 col-sm-6 col-md-4 col-lg-4 region-box">
              #{name_tag}
              #{survey_checkbox_tag}
              #{image}
            </div>
          HTML
        end

        property :id
        property :name

        private

        def checkbox_id
          "interest_regions_survey_region_ids_#{id}"
        end

        def image
          cell(Region::Cell::Image, model).()
        end

        def name_tag
          label_tag(checkbox_id, name, class: 'region-name')
        end

        def survey_checkbox_tag
          check_box_tag(
            'interest_regions_survey[region_ids][]',
            id,
            false,
            class: 'region-checkbox',
            id:    checkbox_id,
          )
        end
      end
    end
  end
end
