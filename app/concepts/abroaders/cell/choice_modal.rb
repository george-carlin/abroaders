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
        property :link_class
        property :link_href
        property :link_id
        property :link_text

        private

        def link
          link_to(
            link_text,
            (link_href || '#'),
            class: "btn btn-info #{link_class}",
            style: "background-color: #35a7ff;",
          )
        end
      end
    end
  end
end
