module Main
  module Cells
    module RegionsOfInterest
      class Survey < Trailblazer::Cell
        # TODO reduce the need for all this boilerplate:
        def self.view_name
          'regions_of_interest/survey'
        end

        def self.prefixes
          ['apps/main/lib/main/views']
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

          # TODO reduce the need for all this boilerplate:
          def self.view_name
            'regions_of_interest/survey/region_input'
          end

          def self.prefixes
            ['apps/main/lib/main/views']
          end

          property :id
          property :code

          private

          def presenter
            @presenter ||= Main::Presenters::Region.present(model)
          end

          def checkbox_id
            "interest_regions_survey_region_ids_#{id}"
          end

          # I feel like this belongs in the presenter rather than in here, but
          # putting 'image_tag' in a new-style presenter (which requires mixing
          # in `ActionView::Helpers::AssetTagHelper`) doesn't add the digest
          # and so the `src` is wrong. Don't have time to investigate now.
          def image
            image_tag("regions/#{code}.jpg", class: 'region-image', style: 'width:100%')
          end

          def name_tag
            label_tag(checkbox_id, presenter.name, class: 'region-name')
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
end
