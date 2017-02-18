module RegionsOfInterest
  module Cell
    class Survey < Trailblazer::Cell
      def title
        'Regions of Interest'
      end

      private

      def regions
        cell(RegionInput, collection: models)
      end

      def models
        ::Region.order(name: :asc)
      end

      class RegionInput < Trailblazer::Cell
        alias region model

        property :id
        property :code
        property :name

        private

        def checkbox_id
          "interest_regions_survey_region_ids_#{id}"
        end

        def image
          cell(Region::Cell::Image, region).()
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
