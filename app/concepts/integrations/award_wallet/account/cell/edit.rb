module Integrations::AwardWallet
  module Account
    module Cell
      # @!method self.call(model, options = {})
      #   @option options [Reform::Form] form
      class Edit < Abroaders::Cell::Base
        include Escaped

        property :display_name
        alias currency_name display_name

        option :form

        def title
          'Edit Award Wallet Account'
        end

        private

        def errors
          cell(Abroaders::Cell::ValidationErrorsAlert, form)
        end

        def form_tag(&block)
          form_for [:integrations, form], &block
        end
      end
    end
  end
end
