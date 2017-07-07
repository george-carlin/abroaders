module RegionsOfInterest
  class Survey < Trailblazer::Operation
    step :setup_regions!

    private

    def setup_regions!(opts)
      opts['regions'] = Region.all.sort_by(&:name)
    end

    class Save < Trailblazer::Operation
      REGION_IDS_TYPE = Types::Strict::Array.member(Types::Form::Int)

      step :get_ids_from_params!
      success :validate_region_ids!
      success :validate_account_in_correct_onboarding_state!
      step Wrap(Abroaders::Transaction) {
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

      def validate_account_in_correct_onboarding_state!(current_account:, **)
        raise 'invalid onboarding state' unless current_account.onboarding_state == 'regions_of_interest'
      end

      def create_regions!(current_account:, region_ids:, **)
        region_ids.uniq.each do |id|
          current_account.interest_regions.create(region_id: id)
        end
      end

      def update_onboarding_state!(current_account:, **)
        Account::Onboarder.new(current_account).add_regions_of_interest!
        true
      end
    end
  end
end
