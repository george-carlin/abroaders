module Abroaders
  module Cell
    class ChoiceModal < Abroaders::Cell::Base
      option :id

      private

      def choices
        cell(Choice, collection: model).join(
          '<p class="lead h23"><span>Or</span></p>',
        )
      end

      class Choice < Abroaders::Cell::Base
        # properties are accessible via model[name], not model.name:
        def self.property(name)
          define_method name do
            model[name]
          end
        end

        property :text
        property :link_text
        property :link_href
        property :link_id
      end
    end
  end
end
