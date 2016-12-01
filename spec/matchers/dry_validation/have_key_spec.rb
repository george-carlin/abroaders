require APP_ROOT.join 'spec', 'support', 'matchers', 'dry_validation', 'have_key'

module Dry::Validation
  describe Matchers do
    include Matchers

    let(:schema) do
      ::Dry::Validation.Schema do
        required(:required_filled).filled
        required(:required_maybe).maybe
        optional(:optional_filled).filled
        optional(:optional_maybe).maybe
      end
    end

    describe Matchers::HaveRequiredKey do
      example 'with .filled option' do
        matcher = have_required_key(:required_filled).filled
        expect(matcher.matches?(schema)).to be true
        expect(matcher.failure_message).to be_nil

        matcher = have_required_key(:required_maybe).filled
        expect(matcher.matches?(schema)).to be false
        expect(matcher.failure_message).to eq \
          "expected the schema to have a required key called 'required_maybe' that must be filled"

        matcher = have_required_key(:optional_filled).filled
        expect(matcher.matches?(schema)).to be false
        expect(matcher.failure_message).to eq \
          "expected the schema to have a required key called 'optional_filled' that must be filled"

        matcher = have_required_key(:optional_maybe).filled
        expect(matcher.matches?(schema)).to be false
        expect(matcher.failure_message).to eq \
          "expected the schema to have a required key called 'optional_maybe' that must be filled"
      end

      example 'with .maybe option' do
        matcher = have_required_key(:required_filled).maybe
        expect(matcher.matches?(schema)).to be false
        expect(matcher.failure_message).to eq \
          "expected the schema to have a required key called 'required_filled' that may be empty"

        matcher = have_required_key(:required_maybe).maybe
        expect(matcher.matches?(schema)).to be true
        expect(matcher.failure_message).to be nil

        matcher = have_required_key(:optional_filled).maybe
        expect(matcher.matches?(schema)).to be false
        expect(matcher.failure_message).to eq \
          "expected the schema to have a required key called 'optional_filled' that may be empty"

        matcher = have_required_key(:optional_maybe).maybe
        expect(matcher.matches?(schema)).to be false
        expect(matcher.failure_message).to eq \
          "expected the schema to have a required key called 'optional_maybe' that may be empty"
      end
    end

    describe Matchers::HaveOptionalKey do
      example 'with .filled option' do
        matcher = have_optional_key(:required_filled).filled
        expect(matcher.matches?(schema)).to be false
        expect(matcher.failure_message).to eq \
          "expected the schema to have an optional key called 'required_filled' that must be filled"

        matcher = have_optional_key(:required_maybe).filled
        expect(matcher.matches?(schema)).to be false
        expect(matcher.failure_message).to eq \
          "expected the schema to have an optional key called 'required_maybe' that must be filled"

        matcher = have_optional_key(:optional_filled).filled
        expect(matcher.matches?(schema)).to be true
        expect(matcher.failure_message).to be nil

        matcher = have_optional_key(:optional_maybe).filled
        expect(matcher.matches?(schema)).to be false
        expect(matcher.failure_message).to eq \
          "expected the schema to have an optional key called 'optional_maybe' that must be filled"
      end

      example 'with .maybe option' do
        matcher = have_optional_key(:required_filled).maybe
        expect(matcher.matches?(schema)).to be false
        expect(matcher.failure_message).to eq \
          "expected the schema to have an optional key called 'required_filled' that may be empty"

        matcher = have_optional_key(:required_maybe).maybe
        expect(matcher.matches?(schema)).to be false
        expect(matcher.failure_message).to eq \
          "expected the schema to have an optional key called 'required_maybe' that may be empty"

        matcher = have_optional_key(:optional_filled).maybe
        expect(matcher.matches?(schema)).to be false
        expect(matcher.failure_message).to eq \
          "expected the schema to have an optional key called 'optional_filled' that may be empty"

        matcher = have_optional_key(:optional_maybe).maybe
        expect(matcher.matches?(schema)).to be true
        expect(matcher.failure_message).to be nil
      end
    end
  end
end
