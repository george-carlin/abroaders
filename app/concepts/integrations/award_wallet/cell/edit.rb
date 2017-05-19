module Integrations::AwardWallet
  module Account
    module Cell
      # @!method self.call(form, options = {})
      #   @param form [Reform::Form]
      class Edit < Abroaders::Cell::Base
        include Escaped

        def title
          'Edit Award Wallet Account'
        end

        private

        def currency_name
          escape!(model.model.display_name)
        end

        def errors
          cell(Abroaders::Cell::ValidationErrorsAlert, model)
        end

        def form_tag(&block)
          form_for [:integrations, model], &block
        end
      end
    end
  end
end
