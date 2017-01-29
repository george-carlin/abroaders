module Abroaders
  module Cell
    class Navbar::Logo < Trailblazer::Cell
      private

      def html_classes
        admin? ? 'admin-navbar' : ''
      end

      def text
        raw("Abroaders#{' <small>(Admin)</small>' if admin?}")
      end

      def admin?
        model.is_a?(Admin)
      end
    end
  end
end
