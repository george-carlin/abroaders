class Person::Cell < Trailblazer::Cell
  class ReadinessIcon < Trailblazer::Cell
    property :ready?
    property :eligible?

    def show
      return '(R)' if ready?
      return '(E)' if eligible?
      ''
    end
  end
end
