module AdminArea
  module CardRecommendations
    class Form < Reform::Form
      feature Coercion
      feature MultiParameterAttributes

      property :applied_on, type: Types::Form::Date
      property :called_at, type: Types::Form::Date
      property :decline_reason, type: Types::StrippedString, nilify: true
      property :declined_at, type: Types::Form::Date
      property :denied_at, type: Types::Form::Date
      property :nudged_at, type: Types::Form::Date
      property :recommended_at, type: Types::Form::Date
      property :redenied_at, type: Types::Form::Date
      property :opened_on, type: Types::Form::Date

      validation do
        validates :decline_reason, presence: true, if: 'declined_at.present?'
        validates :decline_reason, absence: true, unless: 'declined_at.present?'
        validates :recommended_at, presence: true
      end
    end
  end
end
