module Abroaders
  # Phase out ApplicationPresenter in favour of this class. The main difference
  # between this and ApplicationPresenter is that Abroaders::Presenter doesn't
  # store the 'view context' internally. If you want access to methods like
  # number_to_currency or image_tag, mix in the appropriate helper.
  class Presenter < SimpleDelegator
    include I18nWithErrorRaising

    attr_reader :model

    def self.present(object)
      if object.respond_to?(:to_a)
        object.to_a.map { |obj| new(obj) }
      else
        new(object)
      end
    end

    def initialize(model)
      super
      @model = model
    end
  end
end
