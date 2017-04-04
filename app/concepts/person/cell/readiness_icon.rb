class Person < Person.superclass
  module Cell
    class ReadinessIcon < Abroaders::Cell::Base
      property :ready?
      property :eligible?

      def show
        return '(R)' if ready?
        return '(E)' if eligible?
        ''
      end
    end
  end
end
