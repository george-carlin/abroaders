module ZapierWebhooks
  module Card
    # Abstract class; don't instantiate directly
    class CRUD < Job
      def self.enqueue(model)
        super(model, representer_class: ::Card::Representer)
      end
    end
  end
end
