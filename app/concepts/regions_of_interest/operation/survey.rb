module RegionsOfInterest
  module Operation
    class Survey < Trailblazer::Operation
      step :setup_regions!

      private

      def setup_regions!(opts)
        opts['regions'] = Region.all.sort_by(&:name)
      end

      class Save < Trailblazer::Operation
        extend Abroaders::Operation::Transaction

        REGION_IDS_TYPE = Types::Strict::Array.member(Types::Form::Int)

        step :get_ids_from_params!
        success :validate_region_ids!
        success :validate_account_in_correct_onboarding_state!
        step wrap_in_transaction {
          success :create_regions!
          success :update_onboarding_state!
        }

        private

        def get_ids_from_params!(opts, params:, **)
          # If they don't select any regions, then the params won't have a
          # 'interest_regions_survey' key at all, which I don't think is
          # Rails's fault (it's how HTML handles unchecked checkboxes)
          survey_params = params.fetch(:interest_regions_survey, {})
          region_ids    = survey_params.fetch(:region_ids, [])
          opts['region_ids'] = REGION_IDS_TYPE.(region_ids)
        end

        # They shouldn't be able to submit invalid IDs through the form, so
        # there's no need to handle it gracefully.
        def validate_region_ids!(region_ids:, **)
          # succeed if all region IDs in the params are real:
          raise 'invalid ids' if (region_ids - Region.pluck(:id)).any?
        end

        def validate_account_in_correct_onboarding_state!(_opts, account:, **)
          raise 'invalid onboarding state' unless account.onboarding_state == 'regions_of_interest'
        end

        def create_regions!(account:, region_ids:, **)
          region_ids.uniq.each do |id|
            account.interest_regions.create(region_id: id)
          end
        end

        def update_onboarding_state!(_opts, account:, **)
          Account::Onboarder.new(account).add_regions_of_interest!
          true
        end
      end
    end
  end
end
