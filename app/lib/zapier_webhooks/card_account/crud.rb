module ZapierWebhooks
  module CardAccount
    # Abstract class; don't instantiate directly
    class CRUD < Job
      def self.enqueue(model)
        super(model, representer_class: ::Card::Representer)
      end
    end
  end
end
