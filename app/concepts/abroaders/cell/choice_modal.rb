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
          define_method(name) { model.fetch(name) }
        end

        property :text

        # hash with possible attributes:
        #   href (optional, default '#')
        #   text (required)
        #   id (optional)
        #   target (optional)
        #   class (optional)
        property :link

        private

        def link_tag
          link_to(
            link.fetch(:text),
            link.fetch(:href, '#'),
            class: "btn btn-info #{link[:class]}",
            id: link[:id],
            style: "background-color: #35a7ff;",
            target: link[:target],
          )
        end
      end
    end
  end
end
