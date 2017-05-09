class CardRecommendation < CardRecommendation.superclass
  module Cell
    # @!method self.call(rec)
    #   @param rec (CardRecommendation)
    class DeclineForm < Abroaders::Cell::Base
      private

      def form_tag(&block)
        super(
          decline_card_recommendation_path(model),
          class: 'card_recommendation_decline_form',
          method: 'patch',
          style: 'display:none;',
          &block
        )
      end

      def buttons
        cell(
          Abroaders::Cell::ConfirmOrCancelButtons,
          nil,
          small: true,
          class_name: 'card_recommendation_decline',
        )
      end

      # hidden by default, shown when submit fails
      def decline_error_msg
        <<-HTML
        <span class="decline_card_recommendation_error_message" style="display: none;">
          Please include a message
        </span>
        HTML
      end

      def decline_reason_field
        input = text_field(
          :card,
          :decline_reason,
          class: 'card_recommendation_decline_reason input-sm',
          placeholder: "Why don't you want to apply for this card?",
        )
        # JS must add/remove the class 'field_with_errors' to/from this wrapper:
        "<div class='card_recommendation_decline_reason_wrapper'>#{input}</div>"
      end
    end
  end
end
