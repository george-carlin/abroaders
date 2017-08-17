module AdminArea
  module CardProducts
    class Form < Reform::Form
      feature Coercion

      property :annual_fee, type: Types::Form::Float
      property :bank_id, type: Types::Form::Int
      property :personal, type: Types::Form::Bool
      property :currency_id, type: Types::Form::Int
      property :image
      property :name, type: Types::StrippedString
      property :network, type: CardProduct::Network
      property :shown_on_survey, type: Types::Form::Bool
      property :type, type: CardProduct::Type

      validates :annual_fee,
                numericality: { greater_than_or_equal_to: 0 },
                presence: true
      validates :bank_id, presence: true
      validates :image,
                presence: true,
                file_content_type: { allow: %w[image/jpeg image/jpg image/png] },
                file_size: { less_than: 2.megabytes }
      validates :name, presence: true
      validates :network, presence: true
      validates :type, presence: true
    end
  end
end
